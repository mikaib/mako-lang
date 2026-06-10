package parsing.paths;

import lexing.MToken;
import typing.MType;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;

using core.MTokenViewTools;

class MObjectAccessPath {
    public static function intoObjectAccess(left: MExpr, input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        input.expect(TDot, context);
        var rightControl = parser.parseNextExpr();
        var right = switch rightControl {
            case PReturnSome(r): r;
            default: return rightControl;
        }
        return PReturnSome({
            kind: MExprKind.EObjectAccess(left, right),
            pos: {
                path: left.pos.path,
                min: left.pos.min,
                max: input.previous().pos.max,
            },
            type: MType.mono(),
        });
    }
}
