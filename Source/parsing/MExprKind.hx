package parsing;

import parsing.MExpr;
import core.MConst;
import core.MBinop;
import core.MVarDecl;
import core.MFuncDecl;
import core.MUnop;
import core.MOption;

enum MExprKind {
    EBinop(left: MExpr, right: MExpr, op: MBinop);
    EUnop(expr: MExpr, op: MUnop, prefix: Bool);
    EArrayAccess(expr: MExpr, index: MExpr);
    EArrayDecl(values: MExprList);
    ECall(expr: MExpr, args: MExprList);
    EParenthesis(expr: MExpr);
    EBlock(exprs: MExprList);
    EWhile(econd: MExpr, ebody: MExpr);
    EReturn(expr: MExpr);
    EFunction(f: MFuncDecl);
    EIf(econd: MExpr, eif: MExpr, eelse: MOption<MExpr>);
    EVars(decls: Array<MVarDecl>); // mikaib: should be array, for cases like `var a = 1, b = 2;` or tuples `var value, error = func();` (if we support them)
    EConst(const: MConst);
    EBreak;
    EContinue;
}
