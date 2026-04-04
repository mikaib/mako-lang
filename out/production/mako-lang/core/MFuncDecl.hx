package core;
import typing.MType;
import parsing.MExpr;

class MFuncDecl {
    public var name: String = "";
    public var returnType: MType = MType.mono();
    public var args: Array<MFuncArg> = [];
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function toString(): String {
        return "MFuncDecl { \n" +
        "access: " + access + ", \n" +
        "name: " + name + ", \n" +
        "returnType: " + Std.string(returnType) + ", \n" +
        "args: [" + args.join(", ") + "], \n" +
        "expr: " + (if (expr != null) Std.string(expr) else "null") +
        "\n}";
    }

    public function new(){}
}
