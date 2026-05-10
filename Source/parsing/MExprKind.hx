package parsing;

import parsing.MExpr;
import core.MConst;
import core.MBinop;
import core.MVarDecl;
import core.MFuncDecl;
import core.MUnop;
import core.MOption;
import typing.MType;

enum MExprKind {
    EBinop(left: MExpr, right: MExpr, op: MBinop);
    EUnop(expr: MExpr, op: MUnop, prefix: Bool);
    EArrayAccess(expr: MExpr, index: MExpr);
    EArrayDecl(values: MExprList);
    EFunction(f: MFuncDecl);
    EObjectAccess(left: MExpr, right: MExpr);
    ECall(expr: MExpr, args: MExprList);
    EParenthesis(expr: MExpr);
    EBlock(exprs: MExprList);
    EWhile(econd: MExpr, ebody: MExpr, is_do_while: Bool);
    EReturn(expr: MExpr);
    EIf(econd: MExpr, eif: MExpr, eelse: MOption<MExpr>);
    EVars(decls: Array<MVarDecl>); // mikaib: should be array, for cases like tuples `var value, error = func();` (if we support them)
    EConst(const: MConst);
    ECast(expr: MExpr, type: MType);
    EBreak;
    EContinue;
}
