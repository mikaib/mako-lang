package core;

import typing.MType;
import parsing.MExpr;

@:structInit
class MVarDecl {
    public var const: Bool = false;
    public var name: String = "";
    public var type: MType = MType.mono();
    public var expr: Null<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function toString(): String {
//        return "MVarDecl { \n" +
//        "access: " + Std.string(access) + ", \n" +
//        "const: " + const + ", \n" +
//        "names: [" + names.join(", ") + "], \n" +
//        "type: " + Std.string(type) + ", \n" +
//        "expr: " + (if (expr != null) Std.string(expr) else "null") +
//        "\n}";
        return 'MVarDecl(const=${const}, name=${name}, type=${type}, expr=${if (expr != null) Std.string(expr) else "null"}, access=${access})';
    }
}
