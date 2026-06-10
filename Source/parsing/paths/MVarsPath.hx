package parsing.paths;

import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import core.MConst;
import typing.MType;
import haxe.Exception;
import core.MAccessLevel;
import core.MOption;
import core.MOptionKind;
import error.MErrorKind;

using core.MTokenViewTools;

class MVarsPath {
    private static function getVarName(input: ArrayView<MToken>, context: Context): MOption<String> {
        var token = input.peek();

        if (token == null) {
            return None;
        }

        return switch input.next().kind {
            case TConst(CIdent(v)):
                Some(v);

            default:
                context.emitError(MErrorKind.ParserExpectedVariableName, input.intoArray());
                None;
        }
    }

    private static function getVarType(input: ArrayView<MToken>, context: Context): MOption<MType> {
        var token = input.peek();

        if (token == null) {
            return None;
        }

        if (!token.kind.match(TColon)) {
            return Some(MType.mono());
        }

        input.consume(1);

        token = input.peek();

        if (token == null) {
            return None;
        }

        return switch input.next().kind {
            case TConst(CIdent(v)):
                Some(MType.make(v));

            default:
                context.emitError(MErrorKind.ParserExpectedVariableType, input.intoArray());
                None;
        }
    }

    public static function intoEVars(input:ArrayView<MToken>, accessLevel:MAccessLevel, context:Context, parser:MParser): ParserFlowControl {
        if (input.peek() == null) {
            return PParseError;
        }

        var minToken = input.peek();

        var isConst = switch input.next().kind {
            case TKeyword(KConst):
                true;

            case TKeyword(KVar):
                false;

            default:
                throw new Exception('Internal compiler error: Expected const or var, found: ${input.peek()?.kind}');
        };

        var varName = getVarName(input, context);

        if (varName.isNone()) {
            return PParseError;
        }

        var varType = getVarType(input, context);

        if (varType.isNone()) {
            return PParseError;
        }

        var expression: MOption<MExpr> = None;

        var nextToken = input.peek();

        if (nextToken != null && nextToken.kind.match(TTokenOperator(OAssign))) {
            input.consume(1);

            expression = switch parser.parseNextExpr() {
                case PReturnSome(e):
                    Some(e);

                default:
                    return PParseError;
            };
        }

        return PReturnSome({
            kind: MExprKind.EVars([{
                const: isConst,
                name: varName.unwrap(),
                type: varType.unwrap(),
                expr: expression,
                access: accessLevel,
            }]),
            pos: {
                min: minToken.pos.min,
                max: input.previous().pos.max,
                path: minToken.pos.path,
            }
        });
    }
}