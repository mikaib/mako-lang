package parsing.paths;

import core.MArrayView.ArrayView;
import core.MOptionKind;
import lexing.MToken;
import lexing.MTokenKind;
import parsing.MExpr;
import parsing.MParser.ParserFlowControl;
import haxe.Exception;
import error.MErrorKind;
using core.MTokenViewTools;
using core.MTokenViewTools;

class MIfPath {

    private static function parseElse(input: ArrayView<MToken>, currentIf: MExpr, context: Context): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KElse))) {
            switch (currentIf.kind) {
                case EIf(cond, eif, _): currentIf.kind = EIf(cond, eif, None);
                default: throw new Exception("Internal compiler error, reached unreachable path");
            }
            return PReturnSome(currentIf);
        }

        input.expect(TKeyword(KElse), context);

        var eElse: MExpr;
        if (input[0].kind.match(TKeyword(KIf))) {
            return intoEIf(input, context);
        } else {
            eElse = switch new MParser(input, context).parseNextExpr() {
                case PReturnSome(e): e;
                default: return PParseError;
            }
        }

        switch (currentIf.kind) {
            case EIf(cond, eif, _):
                currentIf.kind = EIf(cond, eif, Some(eElse));
            default:
        }
        currentIf.pos.max = eElse.pos.max;
        return PReturnSome(currentIf);
    }

    public static function intoEIf(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KIf))) {
            throw new Exception("Internal compiler error, reached unreachable codo");
        }

        var path = input[0].pos.path;
        var minPos = input[0].pos.min;
        input.consume(1);

        var condition = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserExpectedIfCondition, input.intoArray());
                return PParseError;
        }

        var expression = switch new MParser(input, context).parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserExpectedIfExpression, input.intoArray());
                return PParseError;
        }

        var ifExpr: MExpr = {
            kind: EIf(condition, expression, None),
            pos: {
                path: path,
                min: minPos,
                max: expression.pos.max,
            },
        };

        return parseElse(input, ifExpr, context);
    }
}
