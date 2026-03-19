package core;
import typing.MType;
import parsing.MExpr;

@:structInit
class MFuncDecl {
    public var name: String;
    public var returnType: MType = MType.mono();
    public var args: Array<MFuncArg> = [];
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APublic;
}
