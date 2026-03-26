package core;

import typing.MType;
import parsing.MExpr;

@:structInit
class MVarDecl {
    public var name: String;
    public var const: Bool = false;
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APublic;
}
