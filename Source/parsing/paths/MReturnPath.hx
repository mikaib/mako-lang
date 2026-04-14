package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOptionKind.None;

class MReturnPath {
    public static function intoEReturn(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KReturn))) {
            return PNotParsed;
        }

        var min = input[0];
        var max = input[input.length - 1].pos.max;

        input.consume(1);

        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        var expression = new MParser(block).intoMExpr();
        if (expression.isNone()) {
            return PNotParsed;
        }

        var ret = expression.unwrap();

        return PReturnSome({
            kind: MExprKind.EReturn(ret),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max,
            }
        });
    }
}
