package parsing.paths;

import parsing.MParser.ParserFlowControl;
import lexing.MToken;
import core.MArrayView.ArrayView;
import core.MOptionKind;
import lexing.MTokenKind;
import core.MVarDecl;
import core.MConst;
import haxe.macro.Expr.Access;
import typing.MType;
import parsing.paths.MBlockPath.tryIntoEBlock;
import haxe.Exception;

class MVarsPath {

    public static function tryIntoEVars(input: ArrayView<MToken>): ParserFlowControl {
        var readIndex = 0;
        var variable = new MVarDecl();
        var minToken = input.get(0);

        // Access specifier
        switch (input.get(readIndex).kind) {
            case TKeyword(KPublic):
                variable.access = APublic;
                readIndex += 1;
            case TKeyword(KProtected):
                variable.access = AProtected;
                readIndex += 1;
            case TKeyword(KPrivate):
                variable.access = APrivate;
                readIndex += 1;
            default:
        }

        // Is variable
        switch ([
            input.get(readIndex)?.kind,
            input.get(readIndex + 1)?.kind,
        ]) {
            case [TKeyword(KConst), TKeyword(KVar)]:
                variable.const = true;
                readIndex += 2;

            case [TKeyword(KVar), _]:
                readIndex += 1;

            default:
                return PNotParsed;
        }

        // Variable names
        while(true) {
            switch ([
                input.get(readIndex)?.kind,
                input.get(readIndex + 1)?.kind,
            ]) {
                case [TConst(CIdent(v)), TComma]:
                    variable.names.push(v);
                    readIndex += 2;

                case [TConst(CIdent(v)), _]:
                    variable.names.push(v);
                    readIndex += 1;
                    break;

                default:
                    throw new Exception('Error parsing var: ${input.get(readIndex).kind}');
            }
        }

        // Type
        switch ([
            input.get(readIndex)?.kind,
            input.get(readIndex + 1)?.kind,
        ]) {
            case [TColon, TConst(CIdent(v))]:
                variable.type = MType.make(v);
                readIndex += 2;

            default:
                variable.type = MType.mono();
        }

        if (!Type.enumEq(input.get(readIndex).kind, TTokenOperator(OAssign))) {
            throw new Exception('Expected =, got ${input.get(readIndex).kind}');
        }
        readIndex++;

        input.consume(readIndex);

        // variable expression
        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        trace(block.get(0));
        var max = block.get(block.length - 1).pos.max;
        var expression = tryIntoEBlock(block);
        switch (expression) {
            case PReturnSome(v):
                variable.expr = v;
            case PNotParsed:
                variable.expr = null;
        }

        return PReturnSome(
             {
                 kind: MExprKind.EVars(variable),
                 pos: {
                     min: minToken.pos.min,
                     max: max,
                     path: minToken.pos.path,
                 }
             }
        );
    }
}
