package parsing;
import parsing.MExpr;

enum MExprKind {
    EBlock(exprs: MExprList);
    EConst(const: MConst);
    EBinop(left: MExpr, right: MExpr, op: MBinop);
}
