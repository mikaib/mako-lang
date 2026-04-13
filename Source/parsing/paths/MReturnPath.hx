package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind.MTokenKeyword.KReturn;
import parsing.paths.MBlockPath.MBlockPath.tryIntoEBlock;
import core.MOptionKind.None;
import haxe.Exception;

class MReturnPath {
    public static function tryIntoEReturn(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KReturn))) {
            return PNotParsed;
        }

        var min = input[0].pos.min;

        input.consume(1);

        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        var expression = tryIntoEBlock(block);
        var ret = switch (expression) {
            case PReturnSome(v):
                MExprKind.EReturn(v);
            case PReturnEaten: return PReturnEaten;
            case PNotParsed: return PNotParsed;
        }

        return PReturnSome({
            kind: ret,
            pos: {
                path: input[0].pos.path,
                min: min,
                max: input[0].pos.max,
            }
        });
    }
}
