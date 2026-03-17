package parsing;

import parsing.MExpr;
import core.MConst;
import core.MBinop;

enum MExprKind {
    EBlock(exprs: MExprList);
    EConst(const: MConst);
    EBinop(left: MExpr, right: MExpr, op: MBinop);
}
