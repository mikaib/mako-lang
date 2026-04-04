package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
class MBlockPath {
    public static function tryIntoEBlock(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length < 1) {
            return PNotParsed;
        }
        var minToken = input[0];
        var max = input[input.length - 1].pos.max;

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
