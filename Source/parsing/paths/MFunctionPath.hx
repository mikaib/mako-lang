package parsing.paths;

import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;
import core.MFuncDecl;
import lexing.MTokenKind.MTokenKeyword.KFunc;
import core.MOptionKind;
import lexing.MTokenKind;
import core.MConst;
import typing.MType;
import core.MAccessLevel;
import error.MErrorKind;
import core.MOption;
import core.MFuncArg;

using core.MTokenViewTools;

class MFunctionPath {
    private static function parseFunctionDefArgs(input: ArrayView<MToken>, context: Context, parser: MParser): MOption<Array<MFuncArg>> {
        var arguments: Array<MFuncArg> = [];

        while (!input.peek().kind.match(TParentClose)) {
            final argName = switch (input.next().kind) {
                case TConst(CIdent(name)):
                    name;
                default:
                    context.emitError(MErrorKind.ParserExpectedFunctionArgumentName, input.intoArray());
                    return None;
            }

            if (!input.next().kind.match(TColon)) {
                context.emitError(MErrorKind.ParserExpectedFunctionArgColon, input.intoArray());
                return None;
            }

            final type = switch MConstPath.IntoEConst(input, Some(CIdent("")), context) {
                case PReturnSome(const):
                    switch const.kind {
                        case EConst(CIdent(type)):
                            type;
                        default:
                            return None;
                    }
                default:
                    return None;
            }

            arguments.push({
                name: argName,
                type: MType.make(type),
            });

            if (!input.peek().kind.match(TComma)) {
                break;
            }
            input.consume(1);
        }
        return Some(arguments);
    }

    public static function intoEFunction(input: ArrayView<MToken>, accessLevel: MAccessLevel, context: Context, parser: MParser): ParserFlowControl {
        var func: MFuncDecl = {};
        var minToken = input[0];

        func.access = accessLevel;

        // Is function
        if(!input.expect(TKeyword(KFunc), context)) {
            return PParseError;
        }

        // read name
        switch (input.next().kind) {
            case TConst(CIdent(name)):
                func.name = name;
            default:
                context.emitError(MErrorKind.ParserExpectedFunctionName, input.intoArray());
                return PParseError;
        }

        if(!input.expect(TParentOpen, context)) {
            return PParseError;
        }

        final args = parseFunctionDefArgs(input, context, parser);
        if (args.isNone()) {
            return PParseError;
        }
        func.args = args.unwrap();
        if (!input.expect(TParentClose, context)) {
            return PParseError;
        }

        if (input.peek().kind.match(TFuncAssign)) {
            input.consume(1);
            switch input.next().kind {
                case TConst(CIdent(type)): func.returnType = MType.make(type);
                default: {
                    context.emitError(MErrorKind.ParserExpectedFunctionReturnType, input.intoArray());
                    return PParseError;
                }
            }
        }
        else {
            func.returnType = MType.make("void");
        }

        func.expr = switch parser.parseNextExpr() {
            case PReturnSome(expr):
                expr;
            default:
                return PParseError;
        }

        return PReturnSome({
            kind: MExprKind.EFunction(func),
            pos: {
                path: minToken.pos.path,
                min: minToken.pos.min,
                max: input.previous().pos.max,
            },
            type: MType.callable(func.args.map(arg -> arg.type), func.returnType)
        });
    }
}
