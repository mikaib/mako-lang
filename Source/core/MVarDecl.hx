package core;

import typing.MType;
import parsing.MExpr;

@:structInit
class MVarDecl {
    public var const: Bool;
    public var name: String;
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APublic;
}
