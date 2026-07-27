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
import ir.impl.MIRC;
import parsing.dotter.MDotCreator;

class Main {

    public static function main() {
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
                3;
            } else {
                4;
            };

            var h = if(2 * f < g + 1) {
                3;
            } else if (4 >= 9) {
                5 + 4;
            } else {
                4;
            };

            func mul(a: i32, b: i32) -> i64 {
                var h = 1;
                return 4 + 5;
            }

            func loop() {
                while (1) {

                }

                do {
                    const x: i32 = -4 + ++8 * (9 - 0++) / 5;
                } while (1);

                for(1; 2; 3) {

                }
            }

            func main() {
                mul(1, 2);
                loop();
                w().x().y().z();
                var x = 0.0;
                return 2 + x;
            }
        ";

        var lexer = new MLexer(code, "main.hx");
        var tokens = lexer.lexTokens();
        trace(tokens.map(t -> '\n$t'));

        var parser = new MParser(new ArrayView(tokens), {});
        var ast = parser.parseTree();

        var dot = new MDotCreator();
        dot.fromAST(ast);
        var typer = new MTypeSystem(ast, {});
        typer.run();

        var generator = new MIRGenerator(ast);
        var ir = generator.run();

        var genc = new MIRC(ir);
        var csrc = genc.emitModule();

        var validator = new ir.impl.MIRValidator(ir);
        var issues = validator.validate();
        Sys.println('\nTOTAL OF ${issues.length} ISSUES IN IR!');
        Sys.println(issues.map(x -> '- $x').join('\n'));

        Sys.print(csrc);
    }
}
