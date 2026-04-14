package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import haxe.Exception;

class MBlockPath {
    public static function intoEBlock(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length < 1) {
            return PReturnEaten;
        }
        var minToken = input[0];
        var max = input[input.length - 1].pos.max;

        if (!input[0].kind.match(MTokenKind.TBraceOpen)) {
            throw new Exception('Expected {, found ${input[0].kind}}');
        }
        input.consume(1);

        var parser = new MParser(input);
        var expressions = parser.parseTree();

        if (!input[0].kind.match(MTokenKind.TBraceClose)) {
            throw new Exception('Expected }, found ${input[0].kind}}');
        }
        input.consume(1);
        return PReturnSome({
            kind: MExprKind.EBlock(expressions),
            pos: {
                min: minToken.pos.min,
                max: max,
                path: minToken.pos.path,
            }
        });
    }
}
