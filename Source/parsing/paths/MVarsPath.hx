package parsing.paths;

import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import core.MConst;
import typing.MType;
import haxe.Exception;
import core.MAccessLevel;
import error.MErrorKind;

using core.MTokenViewTools;

class MVarsPath {

    public static function intoEVars(input: ArrayView<MToken>, accessLevel: MAccessLevel, context: Context): ParserFlowControl {
        var readIndex = 0;
        var minToken = input[0];

        // Is variable
        var isConst = switch ([
            input[readIndex]?.kind,
        ]) {
            case [TKeyword(KConst)]:
                readIndex += 1;
                true;
            case [TKeyword(KVar)]:
                readIndex += 1;
                false;
            default:
                throw new Exception('Internal compiler error: Expected const or var, found: ${input[readIndex].kind}');
        };

        // Variable name
        var varName = switch ([
                input[readIndex]?.kind,
            ]) {
                case [TConst(CIdent(v))]:
                    readIndex += 1;
                    v;
                default:
                    context.emitError(MErrorKind.ParserExpectedVariableName, input.intoArray());
                    return PParseError;
            }

        // Type
        var varType = switch ([
            input[readIndex]?.kind,
            input[readIndex + 1]?.kind,
        ]) {
            case [TColon, TConst(CIdent(v))]:
                readIndex += 2;
                MType.make(v);
            default:
                MType.mono();
        }

        input.consume(readIndex);

        input.expect(TTokenOperator(OAssign), context);

        // variable expression
        var max = input[input.length - 1].pos.max;

        var expression = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(e): e;
            default: return PParseError;
        }

        return PReturnSome(
             {
                 kind: MExprKind.EVars([{
                        const: isConst,
                        name: varName,
                        type: varType,
                        expr: expression,
                        access: accessLevel,
                    }]),
                 pos: {
                     min: minToken.pos.min,
                     max: max,
                     path: minToken.pos.path,
                 }
             }
        );
    }
}
