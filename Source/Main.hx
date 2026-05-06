import parsing.MExprList;
import parsing.MExprKind;
import core.MConst;
import core.MBinop;
import typing.MTypeSystem;
import typing.MType;
import lexing.MLexer;
import parsing.MParser;
import core.MArrayView.ArrayView;
import parsing.dotter.MDotCreator;

class Main {

    public static function main() {

        var ast: MExprList = [
            {
                kind: EBlock([
                    {
                        pos: null,
                        kind: EVars([
                            {
                                name: "test",
                                type: MType.mono(),
                            }
                        ])
                    },
                    {
                        pos: null,
                        kind: EBinop({
                            pos: null,
                            kind: EConst(CIdent("test")),
                            type: MType.mono()
                        }, {
                            pos: null,
                            kind: EConst(CFloat("1.5")),
                            type: MType.make("f64")
                        }, MBinop.Assign)
                    },
                    {
                        pos: null,
                        kind: EBinop({
                            pos: null,
                            kind: EConst(CIdent("test")),
                            type: MType.mono()
                        }, {
                            pos: null,
                            kind: EConst(CFloat("1.5")),
                            type: MType.make("f32")
                        }, MBinop.Mul)
                    }
                ]),
                pos: null
            }
        ];

        // Iw + Fq = Fmax(w, q)
        // Iw + Fq = Fmax(w, q) + 1 // 128

        var context: Context = {};
        var typer = new MTypeSystem(ast, context);
        typer.run();

        trace(ast);

        var code = "
            var str = \"Hello there!\\t\\\'whose there\\\'\";
            var int = 4;
            var float = 3.14;
            var bool = true;
            protected const var a: i64 = 0;
            var c = 12.3;
            var d = !c;

            {
                2 + 2 * 9;
            }

            var e = 3 * ++c + 9++;
            var f = 7 * (1 + 1) / 4;

            var g = if(1 == 1) {
                3
            } else {
                4
            };

            var h = if(2 * f < g + 1) {
                3
            } else if (4 >= 9) {
                5 + 4
            } else {
                4
            };

            func mul(a: i32, b: i32) -> i64 {
                var h = 1;
                return 4 + 5;
            }

            func loop() {

            }

            func main() {
                mul(1, 2);
                loop();
            }
        ";

        var lexer = new MLexer(code, "main.hx");
        var tokens = lexer.lexTokens();
        trace(tokens.map(t -> '\n$t'));

        var parser = new MParser(new ArrayView(tokens));
        var ast = parser.parseTree();
        var dotter = new MDotCreator();
        dotter.fromAST(ast);
        trace(ast.map(t -> '\n$t'));
    }

}
