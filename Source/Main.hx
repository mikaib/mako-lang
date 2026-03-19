import parsing.MExprList;
import parsing.MExprKind;
import core.MConst;
import core.MBinop;
import typing.MTypeSystem;
import typing.MType;
import lexing.MLexer;

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

        var code = "
            const x:i32= 0;

            func mul(a: i32, b: i32) -> i32 {
                return a * b;
            }

            var str = \"Hello there!\\t\\\"whose there\\\"\";
            var int = 4;
            var float = 3.14;
            var bool = true;
        ";

        var lexer = new MLexer(code, "main.hx");
        var tokens = lexer.lexTokens();
        trace(tokens.map(t -> '\n$t'));
    }

}
