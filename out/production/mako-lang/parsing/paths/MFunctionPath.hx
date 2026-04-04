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
import parsing.paths.MBlockPath.MBlockPath.tryIntoEBlock;
import haxe.Exception;

class MFunctionPath {
    public static function tryIntoEFunction(input: ArrayView<MToken>): ParserFlowControl {
        var readIndex = 0;
        var func = new MFuncDecl();
        var minToken = input[0];

        // Access specifier
        switch (input[readIndex].kind) {
            case TKeyword(KPublic):
                func.access = APublic;
                readIndex += 1;
            case TKeyword(KProtected):
                func.access = AProtected;
                readIndex += 1;
            case TKeyword(KPrivate):
                func.access = APrivate;
                readIndex += 1;
            default:
        }

        // Is function
        if(!Type.enumEq(input[readIndex].kind, TKeyword(KFunc))) {
            return PNotParsed;
        }
        readIndex += 1;

        // read name
        switch (input[readIndex].kind) {
            case TConst(CIdent(n)):
                func.name = n;
                readIndex += 1;
            default:
                throw new Exception("Function missing name");
        }

        input.consume(readIndex);

        // arguments
        var argBlock = MParseBlocker.createBlock(input, Some(TParantOpen), TParantClose);
        argBlock.consume(1); // Consume TParantOpen

        while (argBlock.length > 0) {
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
                    return PNotParsed;
            }

            if (!Type.enumEq(argBlock[0].kind, TComma)) {
                break;
            }
            argBlock.consume(1);
        }

        switch ([
            input[0]?.kind,
            input[1]?.kind,
        ]) {
            case [TColon, TConst(CIdent(t))]:
                func.returnType = MType.make(t);
                input.consume(2);

            default:
                func.returnType = MType.make("void");
        }

        var funcBlock = MParseBlocker.createBlock(input, Some(TBraceOpen), TBraceClose);
        var max = funcBlock[funcBlock.length - 1].pos.max;
        var expression = tryIntoEBlock(funcBlock);
        switch (expression) {
            case PReturnSome(v):
                func.expr = v;
            case PNotParsed:
                func.expr = null;
        }

        return PReturnSome({
            kind: MExprKind.EFunction(func),
            pos: {
                path: minToken.pos.path,
                min: minToken.pos.min,
                max: max,
            }
        });
    }
}
