package core;

import typing.MType;
import parsing.MExpr;

class MVarDecl {
    public var const: Bool = false;
    public var names: Array<String> = [];
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function new(){}
}
