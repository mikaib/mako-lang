package parsing;

import parsing.MExpr;

@:forward
abstract MExprList(Array<MExpr>) from Array<MExpr> to Array<MExpr> {

    public function last(): MExpr {
        return this[this.length - 1];
    }

}
