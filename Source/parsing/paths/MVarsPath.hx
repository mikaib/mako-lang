package parsing.paths;

import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import core.MVarDecl;
import core.MConst;
import typing.MType;
import haxe.Exception;
import core.MAccessLevel;

class MVarsPath {

    public static function intoEVars(input: ArrayView<MToken>, accessLevel: MAccessLevel, context: Context): ParserFlowControl {
        trace(input.map(t -> '${t.kind}'));
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
                throw new Exception('Expected const or var, found: ${input[readIndex].kind}');
        };

        // Variable name
        var varName = switch ([
                input[readIndex]?.kind,
            ]) {
                case [TConst(CIdent(v))]:
                    readIndex += 1;
                    v;
                default:
                    throw new Exception('Error parsing var: ${input[readIndex].kind}');
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

        if (!input[readIndex].kind.match(TTokenOperator(OAssign))) {
            throw new Exception('Expected =, got ${input[readIndex].kind}');
        }
        readIndex++;

        input.consume(readIndex);

        // variable expression
        var max = input[input.length - 1].pos.max;

        var expression = null;

        var expressionTokens = new MParser(input, context).intoMExpr();
        if (expressionTokens.hasValue()) {
            expression = expressionTokens.unwrap();
        }

        if (expressionTokens.hasValue()) {
            expression = expressionTokens.unwrap();
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
