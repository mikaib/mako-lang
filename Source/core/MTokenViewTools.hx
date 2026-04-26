package core;
import core.MArrayView.ArrayView;
import lexing.MTokenKind;
import haxe.Exception;
import lexing.MToken;

using haxe.EnumTools.EnumValueTools;
using core.MTokenViewTools;

class MTokenViewTools {
    public static function expect(view: ArrayView<MToken>, token: MTokenKind) {
        if (view.length < 1) {
            throw new Exception('Expected ${token}, got empty array');
        }

        if (!view[0].kind.equals(token)) {
            throw new Exception('Expected ${token}, got ${view[0].kind}');
        }

        view.consume(1);
    }

    public static function expectBack(view: ArrayView<MToken>, token: MTokenKind) {
        if (view.length < 1) {
            throw new Exception('Expected ${token}, got empty array');
        }

        if (!view[view.length - 1].kind.equals(token)) {
            throw new Exception('Expected ${token}, got ${view[view.length - 1].kind}');
        }

        view.consumeBack(1);
    }

    public static function splitDepthCounting(view: ArrayView<MToken>, splitter: MTokenKind): Array<ArrayView<MToken>> {
        var arrays = new Array();

        var readIndex = 0;

        var ParantDepth = 0;
        var BraceDepth = 0;
        var BracketDepth = 0;
        while (view.length > readIndex) {
            if (view[readIndex].kind == splitter) {
                if (ParantDepth == 0 && BraceDepth == 0 && BracketDepth == 0) {
                    arrays.push(view.subslice(0, readIndex));
                    view.consume(readIndex);
                    view.expect(splitter);
                    readIndex = 0;
                }
            } else {
                switch (view[readIndex].kind) {
                    case TParantOpen: ParantDepth++;
                    case TParantClose: ParantDepth--;
                    case TBraceOpen: BraceDepth++;
                    case TBraceClose: BraceDepth--;
                    case TBracketOpen: BracketDepth++;
                    case TBracketClose: BracketDepth--;
                    default:
                }
            }
            readIndex++;
        }
        // Push remaining view to the array
        if (view.length > 0) {
            arrays.push(view.subslice(0, view.length));
            view.consume(view.length);
        }
        return arrays;
    }
}
