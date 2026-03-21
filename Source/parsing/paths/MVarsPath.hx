package parsing.paths;

import parsing.MParser.ParserFlowControl;
import haxe.exceptions.NotImplementedException;
import lexing.MToken;
import core.MArrayView.ArrayView;
import core.MOptionKind;
import lexing.MTokenKind;
import core.MVarDecl;
import core.MConst;
import haxe.macro.Expr.Access;
import typing.MType;

class MVarsPath {

    public function tryIntoEVars(input: ArrayView<MToken>): ParserFlowControl {
        //valid
        // var x;
        // var x = 1;
        // var x, y = "s";
        // var x: Int = x;
        // var x, y: Int = 2;

        var read_index = 0;
        var variable = new MVarDecl();

        // Access specifier
        switch (input[read_index].kind) {
            case TKeyword(KPublic):
                variable.access = APublic;
                read_index += 1;
            case TKeyword(KProtected):
                variable.access = AProtected;
                read_index += 1;
            case TKeyword(KPrivate):
                variable.access = APrivate;
                read_index += 1;
        }

        // Is variable
        switch ([
            input[read_index].kind,
            input[read_index + 1].kind,
        ]) {
            case [TKeyword(KConst), KVar]:
                variable.const = true;
                read_index += 2;

            case [KVar, _]:
                read_index += 1;

            default:
                return PAdvance;
        }

        // Variable names
        while(true) {
            switch ([
                input[read_index].kind,
                input[read_index + 1].kind,
            ]) {
                case [TConst(CString(v)), TComma]:
                    variable.names.push(v);
                    read_index += 2;

                case [TConst(CString(v)), _]:
                    variable.names.push(v);
                    read_index += 1;
                    break;

                default:
                    throw NotImplementedException();
            }
        }

        // Type
        switch ([
            input[read_index].kind,
            input[read_index + 1].kind,
        ]) {
            case [TColon, TConst(CString(v))]:
                variable.type = MType.make(v);
                read_index += 2;

            default:
                variable.type = MType.mono();
        }

        if (input[read_index].kind != OEqual) {
            throw new NotImplementedException();
        }

        input.consume(read_index);

        var block = MParseBlocker.createBlock(input, None, TSemiColon);
        var parser = new MParser(block);
        var expression = parser.parseTree();
        variable.expr = {
            kind: MExprKind.EBlock(expression),
            pos: {
                min: {
                    line: block[0].pos.min.line,
                    column: block[0].pos.min.column
                },
                max: {
                    line: block[block.length].pos.max.line,
                    column: block[block.length].pos.max.column
                },
                path: input[0].pos.path,
            }
        }

        input.consume(block.length);

        return PReturnSome(
             {
                 kind: MExprKind.EVars(variable),
                 pos: {
                     min: {
                         line: input[0].pos.min.line,
                         column: input[0].pos.min.column
                     },
                     max: {
                         line: block[block.length].pos.max.line,
                         column: block[block.length].pos.max.column
                     },
                     path: input[0].pos.path,
                 }
             }
        );
    }
}
