package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import error.MErrorKind;
using core.MTokenViewTools;

class MReturnPath {
    public static function intoEReturn(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return PParseError;
        }

        var min = input[0];

        if(!input.expect(TKeyword(KReturn), context)) {
            return PParseError;
        }

        var expressionFlow = parser.parseNextExpr();
        var expression = switch expressionFlow {
            case PReturnSome(e): e;
            case _: return expressionFlow;
        }

        return PReturnSome({
            kind: MExprKind.EReturn(expression),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: input.previous().pos.max,
            }
        });
    }
}
