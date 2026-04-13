package core;

import parsing.MExpr;
import parsing.MExprList;

class MExprTools {

    public static extern inline overload function iterate(list: MExpr, callback: MExpr->Void): Void {
        _iterateExpr(list, callback);
    }

    private static function _iterateExpr(expr: MExpr, callback: MExpr->Void): Void {
        final invoke = (e) -> _iterateExpr(e, callback);

        switch expr.kind {
            case EBlock(list), EArrayDecl(list): for (e in list) invoke(e);
            case EParenthesis(e0), EReturn(e0), EUnop(e0, _): invoke(e0);
            case EBinop(e0, e1, _), EArrayAccess(e0, e1), EWhile(e0, e1): invoke(e0); invoke(e1);
            case EIf(e0, e1, e2): invoke(e0); invoke(e1); if (e2.hasValue()) invoke(e2.unwrap());
            case ECall(e0, list): invoke(e0); for (e in list) invoke(e);
            case EVars(decl): if (decl.expr != null) invoke(decl.expr);
            case EConst(_), EBreak, EContinue, EFunction(_): null;
        }

        callback(expr);
    }

    public static extern inline overload function iterate(list: MExprList, callback: MExpr->Void): Void {
        _iterateList(list, callback);
    }

    private static function _iterateList(list: MExprList, callback: MExpr->Void): Void {
        for (e in list) _iterateExpr(e, callback);
    }

}
