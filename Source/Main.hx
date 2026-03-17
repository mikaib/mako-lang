import parsing.MExprList;
import parsing.MExprKind;
import core.MConst;
import core.MBinop;
import core.MExprTools;
import typing.MTypeSystem;
import typing.MType;

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

        trace(ast);
    }

}
