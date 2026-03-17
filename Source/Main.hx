import core.MExprList;
import core.MExprKind;
import core.MConst;
import core.MBinop;

class Main {

    public static function main() {
        var ast: MExprList = [
            {
                kind: EBlock([
                    {
                        pos: null,
                        kind: EBinop({
                            pos: null,
                            kind: EConst(CFloat("5.0"))
                        }, {
                            pos: null,
                            kind: EConst(CInt("3"))
                        }, MBinop.Mul)
                    }
                ]),
                pos: null
            }
        ];

        trace(ast);
    }

}
