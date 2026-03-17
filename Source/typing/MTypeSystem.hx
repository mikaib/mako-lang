package typing;

import parsing.MExprList;
import parsing.MExpr;
import core.MExprTools;

class MTypeSystem {

    private var _root: MExprList;
    private var _constraints: Array<MTypeConstraint> = [];

    public function new(root: MExprList) {
        _root = root;
    }

    public function run(): Void {
        MExprTools.iterate(_root, makeConstraints);
        solveConstraints();
    }

    public function unify(from: MType, to: MType, bidirectional: Bool): Void {
        _constraints.push({
            bidirectional: bidirectional,
            from: from,
            to: to
        });
    }

    public function makeConstraints(expr: MExpr): Void {
        switch expr.kind {
            case EBinop(e0, e1, _): unify(e0.type, e1.type, true);
            case EConst(CIdent(name)): null; // TODO: impl
            case EBlock(_), EConst(_): null;
        }
    }

    public function solveConstraints(): Void {
        for (c in _constraints) {
            c.flatten(_constraints);
        }

        for (c in _constraints) {

        }
    }

}
