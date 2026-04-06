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
                        kind: EBinop({
                            pos: null,
                            kind: EConst(CFloat("5.0")),
                            type: MType.make("f32")
                        }, {
                            pos: null,
                            kind: EConst(CIdent("test")),
                            type: MType.mono()
                        }, MBinop.Mul)
                    }
                ]),
                pos: null
            }
        ];

        var typer = new MTypeSystem(ast);
        typer.run();

        //trace(ast);

        /*var code = "
            const x:i32= 0;

            func mul(a: i32, b: i32) -> i32 {
                return a * b;
            }

            var str = \"Hello there!\\t\\\"whose there\\\"\";
            var int = 4;
            var float = 3.14;
            var bool = true;
        ";*/

        var code = "
            protected const var a, b: i64 = 0;
            var c = 12.3;
            var d = !c;

            var e = 3 * c + 9;
            var f = 7 * (1 + 1) / 4;

            func mul(a: i32, b: i32): i64 {
                var g = 1;
            }

            func main() {

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
