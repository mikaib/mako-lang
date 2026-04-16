package;

import error.MErrorKind;
import error.MErrorLocale;

@:structInit
class Context {

    private var _errorLocale: MErrorLocale = {};

    public function emitError(kind: MErrorKind, args: Array<Dynamic>) {
        Sys.println(_errorLocale.createMessage(kind, args));
    }

}
