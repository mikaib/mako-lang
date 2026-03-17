package typing;

import parsing.MExprList;
import parsing.MExpr;
import core.MExprTools;
import core.MOption;
import core.MOptionKind;

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

    public function unifyResult(from: MType, to: MType, bidirectional: Bool): MOption<MTypeResult> {
        var result: MOptionKind<MTypeResult> = None;

        if (from.isMono() && !to.isMono()) {
            result = Some({ from: to, to: to });
        }

        if (result == None && bidirectional) {
            return unifyResult(to, from, false);
        }

        return result;
    }

    public function makeConstraints(expr: MExpr): Void {
        switch expr.kind {
            case EBinop(e0, e1, _):
                unify(e0.type, e1.type, true);
                expr.type.setRef(e0.type.concrete());

            case EConst(CIdent(name)): null; // TODO: impl
            case EBlock(_), EConst(_): null;
        }
    }

    public function solveConstraints(): Void {
        for (c in _constraints) {
            c.flatten(_constraints);
        }

        for (c in _constraints) {
            var r = unifyResult(c.from, c.to, c.bidirectional);
            if (!r.hasValue()) {
                continue;
            }

            c.from.setVal(r.unwrap().from.concrete());
            c.to.setVal(r.unwrap().to.concrete());
        }
    }

}
