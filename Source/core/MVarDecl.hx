package core;

import typing.MType;
import parsing.MExpr;

@:structInit
class MVarDecl {
    public var const: Bool;
    public var names: Array<String>;
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function new();
}
