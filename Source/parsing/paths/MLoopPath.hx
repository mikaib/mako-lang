package parsing.paths;

import core.MArrayView.ArrayView;
import lexing.MToken;
import haxe.Exception;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOptionKind;
import typing.MType;
import error.MErrorKind;
import core.MOption;

using core.MTokenViewTools;

class MLoopPath {
    private static function intoDoWhileLoop(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KDo), context);
        var expression = switch parser.parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserDoWhileExpectedExpr, input.intoArray());
                return PParseError;
        }

        input.expect(TKeyword(KWhile), context);
        var condition = switch parser.parseNextExpr() {
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
                max: input.previous().pos.max,

            },
            type: MType.mono(),
        });
    }

    private static function intoWhileLoop(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl{
        final min = input[0];
        input.expect(TKeyword(KWhile), context);
        var condition = switch parser.parseNextExpr() {
            case PReturnSome(c): c;
            default: return PParseError;
        }

        var expression = switch parser.parseNextExpr() {
            case PReturnSome(e): e;
            default: return PParseError;
        }

        return PReturnSome({
            kind: MExprKind.EWhile(condition, expression, false),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: input.previous().pos.max
            },
            type: MType.mono(),
        });
    }

    private static function parseForExpressions(input: ArrayView<MToken>, context: Context, parser: MParser): MOption<MExprList> {
        var exprArr = [];

        switch parser.parseNextExpr() {
            case PReturnSome(e): exprArr.push(e);
            default: return None;
        }
        if(!input.expect(TSemiColon, context)) {
            return None;
        }

        switch parser.parseNextExpr() {
            case PReturnSome(e): exprArr.push(e);
            default: return None;
        }
        if(!input.expect(TSemiColon, context)) {
            return None;
        }

        switch parser.parseNextExpr() {
            case PReturnSome(e): exprArr.push(e);
            default: return None;
        }

        return Some(exprArr);
    }

    private static function intoForLoop(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        final min = input[0];
        input.expect(TKeyword(KFor), context);
        input.expect(TParentOpen, context);
        final partsOption = parseForExpressions(input, context, parser);
        input.expect(TParentClose, context);
        if (partsOption.isNone()) {
            return PParseError;
        }

        var parts = partsOption.unwrap();

        var exprFlowControl = parser.parseNextExpr();
        var expr = switch exprFlowControl {
            case PReturnSome(e): e;
            default: return exprFlowControl;
        }
        return PReturnSome({
            kind: MExprKind.EFor(parts[0], parts[1], parts[2], expr),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: input.previous().pos.max
            },
            type: MType.mono(),
        });
    }

    public static function intoLoop(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0) {
            throw new Exception("Internal compiler error: Input length was 0");
        }

        return switch(input[0].kind) {
            case TKeyword(KDo):
                intoDoWhileLoop(input, context, parser);
            case TKeyword(KWhile):
                intoWhileLoop(input, context, parser);
            case TKeyword(KFor):
                intoForLoop(input, context, parser);
            default:
                throw new Exception('Expected loop, got ${input[0].kind}');
        }
    }
}
