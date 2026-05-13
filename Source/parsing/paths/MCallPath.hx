package parsing.paths;

import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MExprKind;
import parsing.MParser;
import haxe.macro.Expr.Constant;
import lexing.MTokenKind;
import core.MOptionKind;
import core.MTokenViewTools;
import haxe.Exception;
import parsing.MExpr;
import core.MConst;
using core.MTokenViewTools;

class MCallPath {
    public static function isFuncCall(input: ArrayView<MToken>): Bool {
        if (input.length < 3) {
            return false;
        }
        if (!input[0].kind.match(TConst(CIdent(_)))) {
            return false;
        }
        if (!input[1].kind.match(TParentOpen)) {
            return false;
        }
        if (!input[input.length - 1].kind.match(TParentClose)) {
            return false;
        }
        return true;
    }

    public static function parseFuncCall(input: ArrayView<MToken>){
        final min = input[0];

        var funcName = MConstPath.IntoEConst(input.subslice(0, 1));
        var funcNameExpr = switch funcName {
            case PReturnSome(s):
                s;
            default:
                return PNotParsed;
        }
        input.consume(1);

        var block = MParseBlocker.createBlock(input, Some(TParentOpen), TParentClose);
        final max = block[block.length - 1];
        MTokenViewTools.expect(block, TParentOpen);
        MTokenViewTools.expectBack(block, TParentClose);

        var arguments = MTokenViewTools.splitDepthCounting(block, TComma);

        var args = arguments.map(a -> {
            var parser = new MParser(a).intoMExpr();
            if (parser.isNone()) {
                throw new Exception("Unexpected None");
            }
            parser.unwrap();
        });

        var call: MExpr = {
            kind: ECall(funcNameExpr, args),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max,
            },
        };

        if (input.length > 0 && input[0].kind.equals(TDot)) {
            return MObjectAccessPath.intoObjectAccess(call, input);
        }
        return PReturnSome(call);
    }
}
