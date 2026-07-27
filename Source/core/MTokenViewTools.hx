package core;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import lexing.MToken;
import error.MErrorKind;

using haxe.EnumTools.EnumValueTools;
using core.MTokenViewTools;

class MTokenViewTools {
    public static function expect(input: ArrayView<MToken>, token: MTokenKind, context: Context): Bool {
        if (input.peek() == null) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return false;
        }

        if (!input[0].kind.equals(token)) {
            context.emitError(MErrorKind.ParserUnexpectedToken, input.intoArray());
            return false;
        }

        input.consume(1);
        return true;
    }
}
