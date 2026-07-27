package parsing.paths;

import lexing.MToken;
import typing.MType;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;
import haxe.exceptions.NotImplementedException;

using core.MTokenViewTools;

class MObjectAccessPath {
    public static function intoObjectAccess(left: MExpr, input: ArrayView<MToken>): ParserFlowControl {
        input.expect(TDot);
        var rightControl = MCallPath.parseFuncCall(input);
        var right = switch rightControl {
            case PReturnSome(r):
                r;
            case PReturnEaten | PNotParsed:
                throw new NotImplementedException('Expected function, got ${input.map(t -> '${t.kind}')}');
        }
        return PReturnSome({
            kind: MExprKind.EObjectAccess(left, right),
            pos: {
                path: left.pos.path,
                min: left.pos.min,
                max: right.pos.max,
            },
            type: MType.mono(),
        });
    }
}
