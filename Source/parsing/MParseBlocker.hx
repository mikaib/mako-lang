package parsing;
import core.MArrayView.ArrayView;
import lexing.MToken;
import core.MOption;
import haxe.Exception;
import lexing.MTokenKind;

class MParseBlocker {
    public function new();

    public static function createBlock(input: ArrayView<MToken>, openDelimiter: MOption<MToken>, closeDelimiter: MTokenKind): ArrayView<MToken> {
        var depth = 1;
        var read_index = 0;
        while (read_index < input.length && depth > 0) {
            if (openDelimiter.isValue(input[read_index])) {
                depth++;
            } else if (input[read_index] == closeDelimiter) {
                depth--;
            }
            read_index++;
        }

        if (depth != 0) {
            throw new Exception("Could not create block, depth != 0");
        }

        return input.subslice(0, read_index);
    }
}
