import typing.MTypeSystem;
import lexing.MLexer;
import parsing.MParser;
import core.MArrayView.ArrayView;
import sys.io.File;
import ir.gen.MIRGenerator;
import parsing.MExprList;
import parsing.MExpr;
import parsing.MExprKind;
import typing.MType;
import core.MBinop;

class Main {

    public static function main() {
        var code = File.getContent("./Testbed/main.mo");
        var lexer = new MLexer(code, "main.mo");
        var tokens = lexer.lexTokens();
        // trace(tokens.map(t -> '\n$t'));

        // var parser = new MParser(new ArrayView(tokens));
        // var ast = parser.parseTree();
        // var dotter = new MDotCreator();
        // dotter.fromAST(ast);
        // trace(ast.map(t -> '\n$t'));

//        var ast: MExprList = [
//            {
//                kind: EBlock([
//                    {
//                        pos: null,
//                        kind: EVars([
//                            {
//                                name: "test",
//                                type: MType.mono(),
//                                expr: {
//                                    pos: null,
//                                    kind: EConst(CInt("5")),
//                                    type: MType.int(32)
//                                }
//                            }
//                        ])
//                    },
//                    {
//                        pos: null,
//                        kind: EBinop({
//                            pos: null,
//                            kind: EConst(CIdent("test")),
//                            type: MType.mono()
//                        }, {
//                            pos: null,
//                            kind: EConst(CFloat("1.5")),
//                            type: MType.make("f64")
//                        }, MBinop.Assign)
//                    },
//                    {
//                        pos: null,
//                        kind: EBinop({
//                            pos: null,
//                            kind: EConst(CIdent("test")),
//                            type: MType.mono()
//                        }, {
//                            pos: null,
//                            kind: EConst(CFloat("1.5")),
//                            type: MType.make("f32")
//                        }, MBinop.Mul)
//                    }
//                ]),
//                pos: null
//            }
//        ];

        var ast: MExprList = [
            {
                pos: null,
                kind: EFunction({
                    name: "main",
                    returnType: MType.float(64),
                    expr: {
                        pos: null,
                        kind: EBlock([
                            {
                                pos: null,
                                kind: EReturn({
                                    pos: null,
                                    kind: EBinop({
                                        pos: null,
                                        kind: EConst(CInt("1")),
                                        type: MType.int(32)
                                    }, {
                                        pos: null,
                                        kind: EConst(CFloat("2.0")),
                                        type: MType.float(64)
                                    }, MBinop.Add)
                                })
                            }
                        ])
                    }
                })
            }
        ];

        var context: Context = {};
        var typer = new MTypeSystem(ast, context);
        typer.run();
        trace(ast);

        var gen = new MIRGenerator(ast);
        var ir = gen.run();
        // trace(ir);

        var emitter = new ir.impl.MIRC(ir);
        var c_code = emitter.emitModule();
        Sys.println(c_code);

        var validator = new ir.impl.MIRValidator(ir);
        var issues = validator.validate();
        Sys.println('\nTOTAL OF ${issues.length} ISSUES IN IR!');
        Sys.println(issues.map(x -> '- $x').join('\n'));
    }

}
