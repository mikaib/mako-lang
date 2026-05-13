package parsing.paths;
import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import haxe.Exception;
import lexing.MTokenKind;
import core.MArrayView.ArrayView;
import core.MTokenViewTools;
using core.MTokenViewTools;

class MParentPath {
    public static function intoEParent(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        var minToken = input[0];

        input.expect(TParentOpen);


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
            throw new Exception("Closing parenthesis not found");
        }

        // -2: zero indexed + exclude ')'
        var subSlice = input.subslice(0, readIndex);
        input.consume(readIndex);
        input.expect(TParentClose);

        if (subSlice.length < 1) {
            return PReturnEaten;
        }
        var max = subSlice[subSlice.length - 1].pos.max;

        var expressions = new MParser(subSlice, context).parseTree();
        if (expressions.length != 1) {
            throw new Exception('Expected 1 expr, found: ${expressions.length}');
        }
        return PReturnSome({
            kind: MExprKind.EParenthesis(expressions[0]),
            pos: {
                min: minToken.pos.min,
                max: max,
                path: minToken.pos.path,
            }
        });
    }
}
