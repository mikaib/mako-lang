package parsing;
import core.MArrayView.ArrayView;
import lexing.MToken;
import core.MOption;
import haxe.Exception;
import lexing.MTokenKind;

class MParseBlocker {

    public static function createBlock(input: ArrayView<MToken>, openDelimiter: MOption<MTokenKind>, closeDelimiter: MTokenKind): ArrayView<MToken> {
        var depth = 1;
        var readIndex = 0;

        if (openDelimiter.hasValue()) {
            if (!openDelimiter.isValue(input.get(readIndex).kind)) {
                throw new Exception("Failed crating block");
            }
            readIndex++;
        }

        while (readIndex < input.length && depth > 0) {
            if (openDelimiter.isValue(input.get(readIndex).kind)) {
                depth++;
            } else if (input.get(readIndex).kind == closeDelimiter) {
                depth--;
            }
            readIndex++;
        }

        if (depth != 0) {
            throw new Exception("Could not create block, depth != 0");
        }

        var subSlice = input.subslice(0, readIndex);
        input.consume(readIndex);
        return subSlice;
    }
}
