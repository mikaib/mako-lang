package parsing.paths;
import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import error.MErrorKind;
using core.MTokenViewTools;

class MParentPath {
    public static function intoEParent(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        var minToken = input[0];

        input.expect(TParentOpen, context);

        final expression = switch parser.parseNextExpr() {
            case PReturnSome(e): e;
            default: return PParseError;
        }

        input.expect(TParentClose, context);

        return PReturnSome({
            kind: MExprKind.EParenthesis(expression),
            pos: {
                min: minToken.pos.min,
                max: input.previous().pos.max,
                path: minToken.pos.path,
            }
        });
    }
}
