package parsing;

import core.MPositionRange;
import typing.MType;

@:structInit
class MExpr {

    public var kind: MExprKind;
    public var pos:  MPositionRange;
    public var type: MType = MType.TMono;

    public function toString() {
        return 'MExpr(k=${kind}, t=${type}, pos=${pos})';
    }

}
