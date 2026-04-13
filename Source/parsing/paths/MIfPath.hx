package parsing.paths;

import core.MArrayView.ArrayView;
import core.MOptionKind;
import lexing.MToken;
import lexing.MTokenKind;
import parsing.MExpr;
import parsing.MExprKind.EIf;
import parsing.MParser.ParserFlowControl;
import parsing.paths.MBlockPath.tryIntoEBlock;
import haxe.Exception;

class MIfPath {

    private static function parseElse(input: ArrayView<MToken>, currentIf: MExpr): MExpr {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KElse))) {
            switch (currentIf.kind) {
                case EIf(cond, eif, _):
                    currentIf.kind = EIf(cond, eif, None);
                default:
            }
            return currentIf;
        }

        input.consume(1);

        trace(input.map(t -> '${t.kind}}'));

        var eElse: MExpr;
        if (input[0].kind.match(TKeyword(KIf))) {
            var control = tryIntoEIf(input);
            eElse = switch (control) {
                case PReturnSome(v): v;
                case PReturnEaten: throw new Exception("Error parsing else-if");
                case PNotParsed: throw new Exception("Error parsing else-if");
            };
        } else {
            var eElseBlockTokens = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
            eElseBlockTokens.consume(1); // Consume '{'
            var control = tryIntoEBlock(eElseBlockTokens);
            eElse = switch (control) {
                case PReturnSome(v): v;
                case PReturnEaten: throw new Exception("Error parsing else");
                case PNotParsed: throw new Exception("Error parsing else");
            };
        }

        trace('Else parsed: ${eElse.kind}');

        switch (currentIf.kind) {
            case EIf(cond, eif, _):
                currentIf.kind = EIf(cond, eif, Some(eElse));
            default:
        }
        currentIf.pos.max = eElse.pos.max;
        return currentIf;
    }

    public static function tryIntoEIf(input: ArrayView<MToken>): ParserFlowControl {
        if (input.length == 0 || !input[0].kind.match(TKeyword(KIf))) {
            return PNotParsed;
        }

        var path = input[0].pos.path;
        var minPos = input[0].pos.min;
        input.consume(1);

        var condBlock = MParseBlocker.createBlock(input, Some(TParantOpen), TParantClose);
        var condition = tryIntoEBlock(condBlock);
        var cond = switch (condition) {
            case PReturnSome(v): v;
            case PReturnEaten: return PReturnEaten;
            case PNotParsed: return PNotParsed;
        };

        var exprBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        exprBlock.consume(1); // Consume '{'
        var expressionBlock = tryIntoEBlock(exprBlock);
        var expr = switch (expressionBlock) {
            case PReturnSome(v): v;
            case PReturnEaten: return PReturnEaten;
            case PNotParsed: return PNotParsed;
        };

        var ifExpr: MExpr = {
            kind: EIf(cond, expr, None),
            pos: {
                path: path,
                min: minPos,
                max: expr.pos.max,
            },
        };

        return PReturnSome(parseElse(input, ifExpr));
    }
}
