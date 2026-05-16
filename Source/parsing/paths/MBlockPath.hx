package parsing.paths;
import core.MArrayView.ArrayView;
import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import error.MErrorKind;
using core.MTokenViewTools;

class MBlockPath {
    public static function intoEBlock(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return PParseError;
        }

        var minToken = input[0];
        var max = input[input.length - 1].pos.max;

        if(!input.expect(TBraceOpen, context)) {
            return PParseError;
        }
        if(!input.expectBack(TBraceClose, context)) {
            return PParseError;
        }

        var parser = new MParser(input, context);
        var expressions = parser.parseTree();

        return PReturnSome({
            kind: MExprKind.EBlock(expressions),
            pos: {
                min: minToken.pos.min,
                max: max,
                path: minToken.pos.path,
            }
        });
    }
}
