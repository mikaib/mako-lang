package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
using core.MTokenViewTools;

class MBlockPath {
    public static function intoEBlock(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0) {
            return PReturnEaten;
        }

        var minToken = input[0];
        var max = input[input.length - 1].pos.max;

        input.expect(TBraceOpen);
        input.expectBack(TBraceClose);

        var parser = new MParser(input);
        var expressions = parser.parseTree();

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
