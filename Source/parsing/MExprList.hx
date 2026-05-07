package parsing;

import parsing.MExpr;

@:forward
abstract MExprList(Array<MExpr>) from Array<MExpr> to Array<MExpr> {

    public function new() {
        this = [];
    }

    public function last(): MExpr {
        return this[this.length - 1];
    }

    public function each(f: MExpr -> Void): Void {
        for (expr in this) {
            f(expr);
        }
    }

    public function map<T>(f: MExpr -> T): Array<T> {
        var result = new Array<T>();
        for (expr in this) {
            result.push(f(expr));
        }
        return result;
    }

    public function mapAndLast<T>(f: MExpr -> T): T {
        var last: T = null;
        for (expr in this) {
            last = f(expr);
        }
        return last;
    }

}
