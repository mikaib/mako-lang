package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind.MTokenOperator;
import core.MUnop;
import core.MOption;
import core.MOptionKind;
import parsing.paths.MBlockPath.MBlockPath.tryIntoEBlock;
import haxe.Exception;
import lexing.MTokenKind;

class MUnopPath {
    private static function tryIntoUnary(mToken: MTokenKind): MOption<MUnop> {
        switch(mToken) {
            case (TTokenOperator(ONot)):
                return Some(MUnop.Neg);
            case (TTokenOperator(OMinus)):
                return Some(MUnop.Dec);
            case (TTokenOperator(OIncrement)):
                return Some(MUnop.Inc);
            case (TTokenOperator(ODecrement)):
                return Some(MUnop.Dec);
            default:
                return None;
        }
    }

    public static function tryIntoEUnop(input: ArrayView<MToken>): ParserFlowControl {
        var min = input[0];

        var unaryOpt = tryIntoUnary(input[0].kind);

        if (unaryOpt.isNone()) {
            return PNotParsed;
        }

        input.consume(1);

        var unary = unaryOpt.unwrap();

        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        var max = block[block.length - 1].pos.max;
        var expression = tryIntoEBlock(block);
        var expr = switch (expression) {
            case PReturnSome(v):
                v;
            case PNotParsed:
                throw new Exception("Failed parsing block");
        }

        return PReturnSome({
            kind: MExprKind.EUnop(expr, unary),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max,
            }
        });
    }
}
