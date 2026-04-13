package parsing.paths;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;
import haxe.Exception;
class MCallPath {
    private static function parseFuncCall(input: ArrayView<MToken>)) {
    var funcName = switch(input[0]?.kind) {
        case TConst(CIdent(v)):

        default:
            return PNotParsed;
        }
    }

    public static function tryIntoECallPath(input: ArrayView<MToken>): ParserFlowControl {
        switch(input[0]?.kind) {
            case TConst(CIdent(v)):

                readIndex += 2;
            default:
                return PNotParsed;
        }

        return
    }
}
