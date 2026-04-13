package core;

import typing.MType;
import parsing.MExpr;

class MVarDecl {
    public var const: Bool = false;
    public var names: Array<String> = [];
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function toString(): String {
        return "MVarDecl { \n" +
        "access: " + Std.string(access) + ", \n" +
        "const: " + const + ", \n" +
        "names: [" + names.join(", ") + "], \n" +
        "type: " + Std.string(type) + ", \n" +
        "expr: " + (if (expr != null) Std.string(expr) else "null") +
        "\n}";
    }

    public function new(){}
}
