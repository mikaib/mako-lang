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
import core.MOption;
using core.MTokenViewTools;

class MCallPath {
    private static function parseFunctionCallArgs(input:ArrayView<MToken>, context:Context, parser:MParser): MOption<MExprList> {
        var arguments = [];

        while (!input.peek().kind.match(TParentClose)) {
            switch parser.parseNextExpr() {
                case PReturnSome(arg):
                    arguments.push(arg);
                case _:
                    return None;
            }

            if (!input.peek().kind.match(TComma)) {
                break;
            }
            input.consume(1);
        }
        return Some(arguments);
    }

    public static function parseFuncCall(input: ArrayView<MToken>, context: Context, parser: MParser): ParserFlowControl {
        if (input.length == 0) {
            context.emitError(MErrorKind.ParserExpectedFunctionName, input.intoArray());
            return PParseError;
        }
        final firstToken = input[0];

        var funcNameExpr = switch MConstPath.IntoEConst(input, Some(MConst.CIdent("")), context) {
            case PReturnSome(s): s;
            default:
                context.emitError(MErrorKind.ParserExpectedFunctionName, input.intoArray());
                return PParseError;
        }

        if(!input.expect(TParentOpen, context)) {
            return PParseError;
        }

        final args = parseFunctionCallArgs(input, context, parser);
        if (args.isNone()) {
            return PParseError;
        }

        if(!input.expect(TParentClose, context)) {
            return PParseError;
        }

        var call: MExpr = {
            kind: ECall(funcNameExpr, args.unwrap()),
            pos: {
                path: firstToken.pos.path,
                min: firstToken.pos.min,
                max: input.previous().pos.max,
            },
        };

        if (input.length > 0 && input[0].kind.equals(TDot)) {
            return MObjectAccessPath.intoObjectAccess(call, input, context, parser);
        }
        return PReturnSome(call);
    }
}
