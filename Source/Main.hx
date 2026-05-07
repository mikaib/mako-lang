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

        var code = "
            var str = \"Hello there!\\t\\\'whose there\\\'\";
            var int = 4;
            var float = 3.14;
            var bool = true;
            protected const a: i64 = 0;
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

        var validator = new ir.impl.MIRValidator(ir);
        var issues = validator.validate();
        Sys.println('\nTOTAL OF ${issues.length} ISSUES IN IR!');
        Sys.println(issues.map(x -> '- $x').join('\n'));
    }

}
