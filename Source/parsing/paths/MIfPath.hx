package parsing.paths;

import core.MArrayView.ArrayView;
import core.MOptionKind;
import lexing.MToken;
import lexing.MTokenKind;
import parsing.MExpr;
import parsing.MExprKind.EIf;
import parsing.MParser.ParserFlowControl;
import haxe.Exception;
using core.MTokenViewTools;
using core.MTokenViewTools;

class MIfPath {

    private static function parseElse(input: ArrayView<MToken>, currentIf: MExpr): MExpr {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KElse))) {
            switch (currentIf.kind) {
                case EIf(cond, eif, _): currentIf.kind = EIf(cond, eif, None);
                default: throw new Exception("Internal compiler error, reached unreachable path");
            }
            return currentIf;
        }

        input.expect(TKeyword(KElse));

        var eElse: MExpr;
        if (input[0].kind.match(TKeyword(KIf))) {
            var control = intoEIf(input);
            eElse = switch (control) {
                case PReturnSome(v): v;
                case PReturnEaten: throw new Exception("Error parsing else-if");
                case PNotParsed: throw new Exception("Error parsing else-if");
            };
        } else {
            var expr = new MParser(input).parseNextExpr();
            if (expr == None) {
                throw new Exception("Error parsing else");
            }

            eElse = expr.unwrap();
        }

        switch (currentIf.kind) {
            case EIf(cond, eif, _):
                currentIf.kind = EIf(cond, eif, Some(eElse));
            default:
        }
        currentIf.pos.max = eElse.pos.max;
        return currentIf;
    }

    public static function intoEIf(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KIf))) {
            return PNotParsed;
        }

        var path = input[0].pos.path;
        var minPos = input[0].pos.min;
        input.consume(1);

        var cond = new MParser(input).parseNextExpr();
        if (cond == None) {
            throw new Exception("Expected expression, found void");
        }
        var condition = cond.unwrap();

        var expr = new MParser(input).parseNextExpr();
        if (expr == None) {
            throw new Exception("Expected expression, found void");
        }
        var expression = expr.unwrap();

        var ifExpr: MExpr = {
            kind: EIf(condition, expression, None),
            pos: {
                path: path,
                min: minPos,
                max: expression.pos.max,
            },
        };

        return PReturnSome(parseElse(input, ifExpr));
    }
}
