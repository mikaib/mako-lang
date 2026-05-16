package parsing.paths;

import core.MArrayView.ArrayView;
import lexing.MToken;
import haxe.Exception;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOptionKind;
import typing.MType;
import error.MErrorKind;

using core.MTokenViewTools;

class MLoopPath {
    private static function intoDoWhileLoop(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KDo), context);
        var expression = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserDoWhileExpectedExpr, input.intoArray());
                return PParseError;
        }

        input.expect(TKeyword(KWhile), context);
        var condition = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(c): c;
            default:
                context.emitError(MErrorKind.ParserDoWhileExpectedCondition, input.intoArray());
                return PParseError;
        }

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
        input.expect(TKeyword(KWhile), context);
        var condition = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(c): c;
            default: return PParseError;
        }

        var expression = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(e): e;
            default: return PParseError;
        }

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
        input.expect(TKeyword(KFor), context);
        var parentBlock = MParseBlocker.createBlock(input, Some(TParentOpen), TParentClose);
        parentBlock.expect(TParentOpen, context);
        parentBlock.expectBack(TParentClose, context);
        final partsOption = new MParser(parentBlock, context).expectExprs(3);
        if (partsOption.isNone()) {
            return PParseError;
        }

        var parts = partsOption.unwrap();

        var exprFlowControl = new MParser(input, context).parseNextExpr();
        var expr = switch exprFlowControl {
            case PReturnSome(e): e;
            default: return exprFlowControl;
        }
        return PReturnSome({
            kind: MExprKind.EFor(parts[0], parts[1], parts[2], expr),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: expr.pos.max
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
