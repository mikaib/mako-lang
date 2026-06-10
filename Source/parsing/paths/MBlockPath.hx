package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import error.MErrorKind;
using core.MTokenViewTools;

class MBlockPath {
    public static function intoEBlock(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return PParseError;
        }

        var minToken = input.peek();

        if(!input.expect(TBraceOpen, context)) {
            return PParseError;
        }

        var expressions = [];

        while (!input.peek().kind.match(TBraceClose)) {
            switch parser.parseNextExpr() {
                case PReturnSome(e): {
                    expressions.push(e);
                }
                default: break;
            }
        }

        if(!input.expect(TBraceClose, context)) {
            return PParseError;
        }

        return PReturnSome({
            kind: MExprKind.EBlock(expressions),
            pos: {
                min: minToken.pos.min,
                max: input.previous().pos.max,
                path: minToken.pos.path,
            }
        });
    }
}
