package core;

@:structInit
class MExpr {

    public var kind: MExprKind;
    public var pos:  MPositionRange;

    public function toString() {
        return 'MExpr(k=${kind}, pos=${pos})';
    }

}
