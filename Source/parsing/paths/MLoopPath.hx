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
        final min = input[0];
        input.expect(TKeyword(KDo));
        var exprBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        var expression = new MParser(exprBlock).parseTree();
        if (expression.length == 0) {
            throw new Exception("Expected block expression: {}, found void");
        }
        if (expression.length > 1) {
            throw new Exception("Expected one block expression: {}, found multiple");
        }
        input.expect(TKeyword(KWhile));
        var condBlock = MParseBlocker.createBlock(input, Some(TParantOpen), TParantClose);
        final max = condBlock[condBlock.length - 1];
        condBlock.expect(TParantOpen);
        condBlock.expectBack(TParantClose);
        var condition = new MParser(condBlock).parseTree();
        if (condition.length == 0) {
            throw new Exception("Expected condition, found void");
        }
        if (condition.length > 1) {
            throw new Exception("Expected one condition, found multiple");
        }
        return PReturnSome({
            kind: MExprKind.EWhile(condition[0], expression[0], true),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max

            },
            type: MType.mono(),
        });
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
        if (expression.length == 0) {
            throw new Exception("Expected block expression: {}, found void");
        }
        if (expression.length > 1) {
            throw new Exception("Expected one block expression: {}, found multiple");
        }

        return PReturnSome({
            kind: MExprKind.EWhile(condition[0], expression[0], false),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max
            },
            type: MType.mono(),
        });
    }

    private static function intoForLoop(input: ArrayView<MToken>): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KFor));
        var parantBlock = MParseBlocker.createBlock(input, Some(TParantOpen), TParantClose);
        parantBlock.expect(TParantOpen);
        parantBlock.expectBack(TParantClose);
        final parts = parantBlock.splitDepthCounting(TSemiColon);
        for (p in parts) {
            trace(p);
            trace(p.map(t -> '${t}'));
        }
        if (parts.length != 3) {
            throw new Exception('for loop must be in the form of for(...;...;...), found only ${parts.length - 1} semicolons');
        }
        //variable: MExpr, cond: MExpr, condExpr: MExpr
        final variable = new MParser(parts[0]).parseTree();
        final condition = new MParser(parts[1]).parseTree();
        final conditionExpr = new MParser(parts[2]).parseTree();
        if (variable.length > 1) {
            throw new Exception("Error parsing for(...;;)");
        }
        if (condition.length > 1) {
            throw new Exception("Error parsing for(;...;)");
        }
        if (conditionExpr.length > 1) {
            throw new Exception("Error parsing for(;;...)");
        }
        var exprBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        final max = exprBlock[exprBlock.length - 1];
        var expression = new MParser(exprBlock).parseTree();
        if (expression.length == 0) {
            throw new Exception("Expected block expression: {}, found void");
        }
        if (expression.length > 1) {
            throw new Exception("Expected one block expression: {}, found multiple");
        }
        return PReturnSome({
            kind: MExprKind.EFor(variable[0], condition[0], conditionExpr[0], expression[0]),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max
            },
            type: MType.mono(),
        });
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
