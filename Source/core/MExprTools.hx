package core;

import parsing.MExpr;
import parsing.MExprList;

class MExprTools {

    public static extern inline overload function iterate(list: MExpr, callback: MExpr->Void, recursive: Bool = false): Void {
        _iterateExpr(list, callback, recursive);
    }

    private static function _iterateExpr(expr: MExpr, callback: MExpr->Void, recursive: Bool = false): Void {
        final invoke = (e: MExpr) -> {
            if (recursive) _iterateExpr(e, callback, recursive);
        };

        switch expr.kind {
            case EBlock(list), EArrayDecl(list): for (e in list) invoke(e);
            case EParenthesis(e0), EReturn(e0), EUnop(e0, _): invoke(e0);
            case EBinop(e0, e1, _), EArrayAccess(e0, e1), EWhile(e0, e1): invoke(e0); invoke(e1);
            case EIf(e0, e1, e2): invoke(e0); invoke(e1); invoke(e2);
            case ECall(e0, list): invoke(e0); for (e in list) invoke(e);
            case EVars(decls): for (d in decls) if (d.expr != null) invoke(d.expr);
            case EConst(_), EBreak, EContinue, EFunction(_): null;
        }

        callback(expr);
    }

    public static extern inline overload function iterate(list: MExprList, callback: MExpr->Void, recursive: Bool = false): Void {
        _iterateList(list, callback, recursive);
    }

    private static function _iterateList(list: MExprList, callback: MExpr->Void, recursive: Bool = false): Void {
        for (e in list) {
            _iterateExpr(e, callback, recursive);
        }
    }

}
