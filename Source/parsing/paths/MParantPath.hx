package parsing.paths;
import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import haxe.Exception;
import lexing.MTokenKind;
import core.MArrayView.ArrayView;
import core.MTokenViewTools;
using core.MTokenViewTools;

class MParantPath {
    public static function intoEParent(input: ArrayView<MToken>): ParserFlowControl {
        var minToken = input[0];

        input.expect(TParantOpen);


        var readIndex = 0;
        var depth = 1;
        while (input.length > readIndex) {
            if (input[readIndex].kind == TParantOpen) {
                depth++;
            }
            if (input[readIndex].kind == TParantClose) {
                depth--;
            }
            if (depth == 0) {
                break;
            }
            readIndex++;
        }

        // Check depth == 0 again, might have exited by EOF
        if (depth != 0) {
            throw new Exception("");
        }

        // -2: zero indexed + exclude ')'
        var subSlice = input.subslice(0, readIndex);
        trace('${subSlice.map(t -> '${t.kind}')}');
        input.consume(readIndex);
        input.expect(TParantClose);

        if (subSlice.length < 1) {
            return PReturnEaten;
        }
        var max = subSlice[subSlice.length - 1].pos.max;

        var parser = new MParser(subSlice);
        var expressions = parser.parseTree();
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
