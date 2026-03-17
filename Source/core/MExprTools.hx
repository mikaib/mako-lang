package core;

import parsing.MExpr;
import parsing.MExprList;

class MExprTools {

    public static extern inline overload function iterate(list: MExpr, callback: MExpr->Void): Void {
        _iterateExpr(list, callback);
    }

    private static function _iterateExpr(expr: MExpr, callback: MExpr->Void): Void {
        final invoke = (e: MExpr) -> {
            _iterateExpr(e, callback);
            callback(e);
        };

        switch expr.kind {
            case EBlock(list): for (e in list) invoke(e);
            case EBinop(e0, e1, _): invoke(e0); invoke(e1);
            case EConst(_): null;
        }
    }

    public static extern inline overload function iterate(list: MExprList, callback: MExpr->Void): Void {
        _iterateList(list, callback);
    }

    private static function _iterateList(list: MExprList, callback: MExpr->Void): Void {
        for (e in list) {
            _iterateExpr(e, callback);
        }
    }

}
