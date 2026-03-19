package parsing;

import parsing.MExpr;
import core.MConst;
import core.MBinop;
import core.MVarDecl;
import core.MFuncDecl;
import core.MUnop;

enum MExprKind {
    EBinop(left: MExpr, right: MExpr, op: MBinop);
    EUnop(expr: MExpr, op: MUnop);
    EArrayAccess(expr: MExpr, index: MExpr);
    EArrayDecl(values: MExprList);
    ECall(expr: MExpr, args: MExprList);
    EParenthesis(expr: MExpr);
    EBlock(exprs: MExprList);
    EWhile(econd: MExpr, ebody: MExpr);
    EReturn(expr: MExpr);
    EFunction(f: MFuncDecl);
    EIf(econd: MExpr, eif: MExpr, eelse: MExpr);
    EVars(decls: Array<MVarDecl>);
    EConst(const: MConst);
    EBreak;
    EContinue;
}
