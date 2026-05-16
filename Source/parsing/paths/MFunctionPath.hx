package parsing.paths;

import lexing.MToken;
import parsing.MParser.ParserFlowControl;
import core.MArrayView.ArrayView;
import core.MFuncDecl;
import lexing.MTokenKind.MTokenKeyword.KFunc;
import core.MOptionKind;
import lexing.MTokenKind;
import core.MConst.CIdent;
import typing.MType;
import parsing.paths.MBlockPath;
import core.MAccessLevel;
import error.MErrorKind;

using core.MTokenViewTools;

class MFunctionPath {
    public static function intoEFunction(input: ArrayView<MToken>, accessLevel: MAccessLevel, context: Context): ParserFlowControl {
        var readIndex = 0;
        var func: MFuncDecl = {};
        var minToken = input[0];

        func.access = accessLevel;

        // Is function
        if(!input.expect(TKeyword(KFunc), context)) {
            return PParseError;
        }

        // read name
        switch (input[readIndex].kind) {
            case TConst(CIdent(n)):
                func.name = n;
                readIndex += 1;
            default:
                context.emitError(MErrorKind.ParserExpectedFunctionName, input.intoArray());
                return PParseError;
        }

        input.consume(readIndex);

        // arguments
        var argBlock = MParseBlocker.createBlock(input, Some(TParentOpen), TParentClose);
        if(!argBlock.expect(TParentOpen, context)) {
            return PParseError;
        }

        while (argBlock.length > 0) {
            if (argBlock[0].kind.match(TParentClose)) {
                argBlock.consume(1);
                break;
            }

            switch ([
                argBlock[0]?.kind,
                argBlock[1]?.kind,
                argBlock[2]?.kind,
            ]) {
                case [TConst(CIdent(n)), TColon, TConst(CIdent(t))]:
                    func.args.push({
                        name: n,
                        type: MType.make(t),
                    });
                    argBlock.consume(3);

                default:
                    context.emitError(MErrorKind.ParserExpectedTypedParam, argBlock.intoArray());
                    return PParseError;
            }

            if (!argBlock[0].kind.match(TComma)) {
                argBlock.expect(TParentClose, context);
                break;
            }
            argBlock.consume(1);
        }

        switch ([
            input[0]?.kind,
            input[1]?.kind,
        ]) {
            case [TFuncAssign, TConst(CIdent(t))]:
                func.returnType = MType.make(t);
                input.consume(2);

            default:
                func.returnType = MType.make("void");
        }

        var funcBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        var max = funcBlock[funcBlock.length - 1].pos.max;
        var expression = MBlockPath.intoEBlock(funcBlock, context);
        switch (expression) {
            case PReturnSome(v):
                func.expr = v;
            default:
                func.expr = null;
        }

        return PReturnSome({
            kind: MExprKind.EFunction(func),
            pos: {
                path: minToken.pos.path,
                min: minToken.pos.min,
                max: max,
            },
            type: MType.callable(func.args.map(arg -> arg.type), func.returnType)
        });
    }
}
