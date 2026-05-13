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
    private static function intoDoWhileLoop(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KDo));
        var expr = new MParser(input, context).parseNextExpr();
        if (expr == None) {
            throw new Exception("Expected expression, found void");
        }
        var expression = expr.unwrap();

        input.expect(TKeyword(KWhile));
        var cond = new MParser(input, context).parseNextExpr();
        if (cond == None) {
            throw new Exception("Expected expression, found void");
        }
        var condition = cond.unwrap();
        return PReturnSome({
            kind: MExprKind.EWhile(condition, expression, true),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: condition.pos.max,

            },
            type: MType.mono(),
        });
    }

    private static function intoWhileLoop(input: ArrayView<MToken>, context: Context): ParserFlowControl{
        final min = input[0];
        input.expect(TKeyword(KWhile));
        var cond = new MParser(input, context).parseNextExpr();
        if (cond == None) {
            throw new Exception("Expected expression, found void");
        }
        var condition = cond.unwrap();


        var expr = new MParser(input, context).parseNextExpr();
        if (expr == None) {
            throw new Exception("Expected expression, found void");
        }
        var expression = expr.unwrap();

        return PReturnSome({
            kind: MExprKind.EWhile(condition, expression, false),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: expression.pos.max
            },
            type: MType.mono(),
        });
    }

    private static function intoForLoop(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KFor));
        var parentBlock = MParseBlocker.createBlock(input, Some(TParentOpen), TParentClose);
        parentBlock.expect(TParentOpen);
        parentBlock.expectBack(TParentClose);
        final parts = new MParser(parentBlock, context).expectExprs(3, None);

        var expr = new MParser(input, context).parseNextExpr();
        if (expr == None) {
            throw new Exception("Expected expression, found void");
        }
        var expression = expr.unwrap();
        return PReturnSome({
            kind: MExprKind.EFor(parts[0], parts[1], parts[2], expression),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: expression.pos.max
            },
            type: MType.mono(),
        });
    }

    public static function intoLoop(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        if (input.length == 0) {
            throw new Exception("Internal compiler error: Input length was 0");
        }

        return switch(input[0].kind) {
            case TKeyword(KDo):
                intoDoWhileLoop(input, context);
            case TKeyword(KWhile):
                intoWhileLoop(input, context);
            case TKeyword(KFor):
                intoForLoop(input, context);
            default:
                throw new Exception('Expected loop, got ${input[0].kind}');
        }
    }
}
