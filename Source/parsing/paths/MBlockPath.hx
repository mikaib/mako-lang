package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
class MBlockPath {
    public function new();

    public static function tryIntoEBlock(input: ArrayView<MToken>): ParserFlowControl {
        var parser = new MParser(input);
        var expressions = parser.parseTree();
        return PReturnSome({
            kind: MExprKind.EBlock(expressions),
            pos: {
                min: {
                    line: input[0].pos.min.line,
                    column: input[0].pos.min.column
                },
                max: {
                    line: input[input.length].pos.max.line,
                    column: input[input.length].pos.max.column
                },
                path: input[0].pos.path,
            }
        });
    }
}
