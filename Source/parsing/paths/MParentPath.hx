package parsing.paths;
import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import error.MErrorKind;
using core.MTokenViewTools;

class MParentPath {
    public static function intoEParent(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        var minToken = input[0];

        input.expect(TParentOpen, context);

        var readIndex = 0;
        var depth = 1;
        while (input.length > readIndex) {
            if (input[readIndex].kind == TParentOpen) {
                depth++;
            }
            if (input[readIndex].kind == TParentClose) {
                depth--;
            }
            if (depth == 0) {
                break;
            }
            readIndex++;
        }

        // Check depth == 0 again, might have ended the loop by running out of tokens
        if (depth != 0) {
            context.emitError(MErrorKind.ParserMissingClosingParenthesis, input.intoArray());
            return PParseError;
        }

        var subSlice = input.subslice(0, readIndex);
        input.consume(readIndex);
        var max = input[0].pos.max;
        input.expect(TParentClose, context);

        if (subSlice.length < 1) {
            context.emitError(MErrorKind.ParserExpectedExprInParenthesis, input.intoArray());
            return PParseError;
        }

        var expression = switch new MParser(subSlice, context).parseNextExpr() {
            case PReturnSome(e): e;
            default: return PParseError;
        }
        if (subSlice.length > 0) {
            context.emitError(MErrorKind.ParserExpectedStreamEnd, subSlice.intoArray());
            return PParseError;
        }
        return PReturnSome({
            kind: MExprKind.EParenthesis(expression),
            pos: {
                min: minToken.pos.min,
                max: max,
                path: minToken.pos.path,
            }
        });
    }
}
