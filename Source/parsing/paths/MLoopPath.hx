package parsing.paths;

import core.MArrayView.ArrayView;
import lexing.MToken;
import haxe.Exception;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOptionKind;
import typing.MType;

using core.MTokenViewTools;

class MLoopPath {
    private static function intoDoWhileLoop(input: ArrayView<MToken>): ParserFlowControl {
        //do
        //block
        //    ...
        //while
        //cond
        return PNotParsed;
    }

    private static function intoWhileLoop(input: ArrayView<MToken>): ParserFlowControl{
        final min = input[0];
        input.expect(TKeyword(KWhile));
        var condBlock = MParseBlocker.createBlock(input, Some(TParantOpen), TParantClose);
        condBlock.expect(TParantOpen);
        condBlock.expectBack(TParantClose);
        var condition = new MParser(condBlock).parseTree();
        if (condition.length == 0) {
            throw new Exception("Expected condition, found void");
        }
        if (condition.length > 1) {
            throw new Exception("Expected one condition, found multiple");
        }

        var exprBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        final max = exprBlock[exprBlock.length - 1];
        var expression = new MParser(exprBlock).parseTree();
        if (condition.length == 0) {
            throw new Exception("Expected block expression: {}, found void");
        }
        if (condition.length > 1) {
            throw new Exception("Expected one block expression: {}, found multiple");
        }

        return PReturnSome({
            kind: MExprKind.EWhile(condition[0], expression[0]),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max

            },
            type: MType.mono(),
        });
    }

    private static function intoForLoop(input: ArrayView<MToken>): ParserFlowControl {
        //for
        //startExpr
        //cond
        //runExpr
        //block
        //    ...

        return PNotParsed;
    }

    public static function intoLoop(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0) {
            throw new Exception("Internal compiler error: Input length was 0");
        }

        return switch(input[0].kind) {
            case TKeyword(KDo):
                intoDoWhileLoop(input);
            case TKeyword(KWhile):
                intoWhileLoop(input);
            case TKeyword(KFor):
                intoForLoop(input);
            default:
                throw new Exception('Expected loop, got ${input[0].kind}');
        }
    }
}
