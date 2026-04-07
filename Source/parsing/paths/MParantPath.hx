package parsing.paths;
import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.paths.MBlockPath.tryIntoEBlock;
import haxe.Exception;
import lexing.MTokenKind;
import parsing.MExprKind.EBlock;

class MParantPath {
    public static function tryIntoEParants(input: ArrayView<MToken>): ParserFlowControl {
        if (!Type.enumEq(input[0]?.kind, TParantOpen)) {
            return PNotParsed;
        }

        var readIndex = 0;
        var depth = 0;
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

        // 1, -1: exclude parathesis
        var subSlice = input.subslice(1, readIndex - 1);
        input.consume(readIndex);

        if (subSlice.length < 1) {
            return PReturnEaten;
        }
        var minToken = subSlice[0];
        var max = subSlice[input.length - 1].pos.max;

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

        return tryIntoEBlock(subSlice);
    }
}
