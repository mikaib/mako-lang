package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOptionKind.None;
import error.MErrorKind;
using core.MTokenViewTools;

class MReturnPath {
    public static function intoEReturn(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return PParseError;
        }

        var min = input[0];
        var max = input[input.length - 1].pos.max;

        input.expect(TKeyword(KReturn), context);

        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        var expressionFlow = new MParser(block, context).parseNextExpr();
        var expression = switch expressionFlow {
            case PReturnSome(e): e;
            case _: return expressionFlow;
        }
        if (block.length > 0) {
            context.emitError(MErrorKind.ParserExpectedStreamEnd, block.intoArray());
            return PParseError;
        }

        return PReturnSome({
            kind: MExprKind.EReturn(expression),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max,
            }
        });
    }
}
