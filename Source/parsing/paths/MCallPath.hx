package parsing.paths;

import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MExprKind;
import parsing.MParser;
import haxe.macro.Expr.Constant;
import lexing.MTokenKind;
import core.MOptionKind;
import core.MTokenViewTools;
import parsing.MExpr;
import core.MConst;
import error.MErrorKind;
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

    public static function parseFuncCall(input: ArrayView<MToken>, context: Context): ParserFlowControl{
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserExpectedFunctionName, input.intoArray());
            return PParseError;
        }
        final min = input[0];

        var funcName = MConstPath.IntoEConst(input.subslice(0, 1), context);
        var funcNameExpr = switch funcName {
            case PReturnSome(s): s;
            default: return PParseError;
        }
        input.consume(1);

        var block = MParseBlocker.createBlock(input, Some(TParentOpen), TParentClose);
        final max = block[block.length - 1];
        if(!MTokenViewTools.expect(block, TParentOpen, context)) {
            return PParseError;
        }
        if(!MTokenViewTools.expectBack(block, TParentClose, context)) {
            return PParseError;
        }

        final argumentsResult = MTokenViewTools.splitDepthCounting(block, TComma, context);
        if (argumentsResult.isErr()) {
            return PParseError;
        }
        final arguments = argumentsResult.unwrap();

        var args = [];
        for (a in arguments) {
            var parser = new MParser(a, context).intoMExpr();
            if (parser.isNone()) {
                return PParseError;
            }
            args.push(parser.unwrap());
        }

        var call: MExpr = {
            kind: ECall(funcNameExpr, args),
            pos: {
                path: min.pos.path,
                min: min.pos.min,
                max: max.pos.max,
            },
        };

        if (input.length > 0 && input[0].kind.equals(TDot)) {
            return MObjectAccessPath.intoObjectAccess(call, input, context);
        }
        return PReturnSome(call);
    }
}
