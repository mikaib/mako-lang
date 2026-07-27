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

    private static function parseElse(input: ArrayView<MToken>, currentIf: MExpr, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0 || !input.peek().kind.match(TKeyword(KElse))) {
            switch (currentIf.kind) {
                case EIf(cond, eif, _): currentIf.kind = EIf(cond, eif, None);
                default: throw new Exception("Internal compiler error, reached unreachable path");
            }
            return PReturnSome(currentIf);
        }

        input.expect(TKeyword(KElse), context);

        var eElse: MExpr;
        if (input.peek().kind.match(TKeyword(KIf))) {
            eElse = switch intoEIf(input, context, parser) {
                case PReturnSome(mIf): mIf;
                default: return PParseError;
            }
        } else {
            eElse = switch parser.parseNextExpr() {
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

    public static function intoEIf(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0) {
            throw new Exception("Internal compiler error, reached unreachable codo");
        }

        var min = input[0];

        if (!input.expect(TKeyword(KIf), context)) {
            return PParseError;
        }

        var condition = switch parser.parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserExpectedIfCondition, input.intoArray());
                return PParseError;
        }

        var expression = switch parser.parseNextExpr() {
            case PReturnSome(e): e;
            default:
                context.emitError(MErrorKind.ParserExpectedIfExpression, input.intoArray());
                return PParseError;
        }

        var ifExpr: MExpr = {
            kind: EIf(condition, expression, None),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: input.previous().pos.max,
            },
        };

        return parseElse(input, ifExpr, context, parser);
    }
}
