package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
class MBlockPath {
    public static function tryIntoEBlock(input: ArrayView<MToken>): ParserFlowControl {
        var parser = new MParser(input);
        var expressions = parser.parseTree();
        return PReturnSome({
            kind: MExprKind.EBlock(expressions),
            pos: {
                min: {
                    line: input.get(0).pos.min.line,
                    column: input.get(0).pos.min.column
                },
                max: {
                    line: input.get(input.length).pos.max.line,
                    column: input.get(input.length).pos.max.column
                },
                path: input.get(0).pos.path,
            }
        });
    }
}
