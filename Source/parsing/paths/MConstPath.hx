package parsing.paths;

import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import core.MPositionRange;
import lexing.MTokenKind.TConst;

class MConstPath {
    public static function tryIntoEConst(input: ArrayView<MToken>): ParserFlowControl {
        var min = input.get(0);
        var expr = switch (input.get(0).kind) {
            case TConst(c):
                input.consume(1);
                MExprKind.EConst(c);
            case _:
                return PNotParsed;
        }

        return PReturnSome( {
            kind: expr,
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: min.pos.max,
            }
        });
    }
}
