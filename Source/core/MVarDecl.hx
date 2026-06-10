package core;

import typing.MType;
import parsing.MExpr;

@:structInit
class MVarDecl {
    public var const: Bool = false;
    public var name: String = "";
    public var type: MType = MType.mono();
    public var expr: MOption<MExpr> = null;
    public var access: MAccessLevel = APrivate;

    public function toString(): String {
        return 'MVarDecl(const=${const}, name=${name}, type=${type}, expr=${if (expr != null) Std.string(expr) else "null"}, access=${access})';
    }
}
