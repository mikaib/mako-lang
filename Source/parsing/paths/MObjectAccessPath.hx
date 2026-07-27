package parsing.paths;

import lexing.MToken;
import typing.MType;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;
import parsing.MExprKind;

using core.MTokenViewTools;

class MObjectAccessPath {
    public static function intoObjectAccess(left: MExpr, input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if(!input.expect(TDot, context)) {
            return PParseError;
        }

        var rightControl = parser.parseNextExpr();
        var right = switch rightControl {
            case PReturnSome(r): r;
            default: return rightControl;
        }

        var exprControl = PReturnSome({
            kind: EObjectAccess(left, right),
            pos: {
                path: left.pos.path,
                min: left.pos.min,
                max: input.previous().pos.max,
            },
            type: MType.mono(),
        });

        var expr = switch exprControl {
            case PReturnSome(expr): expr;
            case PParseError: return PParseError;
        }

        if (input.peek() != null) {
            if (input.peek().kind.match(TDot)) {
                return intoObjectAccess(expr, input, context, parser);
            }
        }

        return exprControl;
    }
}
