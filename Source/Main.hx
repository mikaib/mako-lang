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
import ir.MIRProgram;
import ir.MIRInstructionKind;
import ir.MIROperand;

class Main {

    public static function main() {
        var ir: MIRProgram = [
            {
                name: "add",
                parameters: [
                    { name: "x", register: 0, type: MType.int(32) },
                    { name: "y", register: 1, type: MType.int(32) }
                ],
                returnType: MType.float(32),
                instructions: [
                    {
                        kind: MIRInstructionKind.Add,
                        data: [MIROperand.Register(0), MIROperand.Register(1)],
                        result: {
                            register: 2,
                            type: MType.int(32)
                        }
                    },
                    {
                        kind: MIRInstructionKind.Cast,
                        data: [MIROperand.Register(2), MIROperand.Type(MType.float(32))],
                        result: {
                            register: 3,
                            type: MType.float(32)
                        }
                    },
                    {
                        kind: MIRInstructionKind.Return,
                        data: [MIROperand.Register(3)]
                    }
                ]
            },
            {
                name: "main",
                instructions: [
                    {
                        kind: MIRInstructionKind.Call,
                        data: [MIROperand.Function("add"), MIROperand.Int(5), MIROperand.Register(0)],
                        result: {
                            register: 0,
                            type: MType.float(32)
                        }
                    },
                    {
                        kind: MIRInstructionKind.Return,
                        data: [MIROperand.Register(0)]
                    }
                ]
            }
        ];

        return;
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
        return;

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

            func mul(a: i32, b: i32): i64 {
                var h = 1;
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
