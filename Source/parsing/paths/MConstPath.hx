package parsing.paths;

import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind.TConst;
import core.MConst;
import typing.MType;

class MConstPath {
    public static function IntoEConst(input: ArrayView<MToken>): ParserFlowControl {
        var min = input[0];
        var const= switch (input[0].kind) {
            case TConst(c):
                input.consume(1);
                c;
            case _:
                return PNotParsed;
        }

        var type = switch (const) {
            case CFloat(_): MType.float(32);
            case CInt(_): MType.int(32);
            case CBool(_): MType.bool();
            case CString(_): MType.string();
            case _: MType.mono();
        }

        return PReturnSome( {
            kind: MExprKind.EConst(const),
            type: type,
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: min.pos.max,
            }
        });
    }
}
