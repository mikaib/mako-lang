package typing;

import parsing.MExprList;
import parsing.MExpr;
import core.MExprTools;
import error.MErrorKind;

class MTypeSystem {

    private var _root: MExprList;
    private var _constraints: Array<MTypeConstraint> = [];
    private var _context: Context;
    public var subst: MSubstitution = {};

    public function new(root: MExprList, context: Context) {
        _root = root;
        _context = context;
    }

    public function run(): Void {
        for (e in _root) makeConstraintsIter(e, {});
        solveConstraints();
        MExprTools.iterate(_root, applySubst);
    }

    public function unify(a: MType, b: MType): Void {
        _constraints.push({ from: a, to: b });
    }

    public function solveConstraints(): Void {
        for (c in _constraints) {
            var r = unifyStep(c.from, c.to);
            if (r != null) {
                subst.bind(c.from.id(), r);
                subst.bind(c.to.id(), r);
            }
        }
    }

    public function unifyStep(a: MType, b: MType): MType {
        var ra = subst.apply(a);
        var rb = subst.apply(b);

        if (!ra.isMono() && !rb.isMono()) {
            var cst = implicitCast(ra, rb);
            if (cst == null) {
                _context.emitError(MErrorKind.TyperUnificationFailed, [ra, rb]);
                return null;
            }

            for (i in 0...ra.concrete.params.length) {
                var pr = unifyStep(ra.concrete.params[i], rb.concrete.params[i]);
                if (pr == null) {
                    return null;
                }
            }

            subst.bind(ra.id(), cst);
            subst.bind(rb.id(), cst);

            return cst;
        }

        if (ra.isMono() && rb.isMono() && ra.id() == rb.id()) {
            return ra;
        }

        var mono = ra.isMono() ? ra : rb;
        var other = ra.isMono() ? rb : ra;

        if (subst.occurs(mono.id(), other)) {
            _context.emitError(MErrorKind.TyperOccursCheckFailed, [mono, other]);
            return null;
        }

        subst.bind(mono.id(), other);
        return other;
    }

    public function implicitCast(a: MType, b: MType): MType {
        if (a.concrete.name == b.concrete.name) return a;

        var wa = a.concrete.width();
        var wb = b.concrete.width();

        var aIsInt = a.concrete.isInt();
        var bIsInt = b.concrete.isInt();
        var aIsUInt = a.concrete.isUInt();
        var bIsUInt = b.concrete.isUInt();
        var aIsFloat = a.concrete.isFloat();
        var bIsFloat = b.concrete.isFloat();

        if (aIsFloat && bIsFloat) {
            return wa >= wb ? a : b;
        }

        if ((aIsInt || aIsUInt) && (bIsInt || bIsUInt)) {
            return MType.int(wa >= wb ? wa : wb);
        }

        if ((aIsInt || aIsUInt) && bIsFloat) {
            return MType.float(wb >= wa ? wb : wa);
        }

        if (aIsFloat && (bIsInt || bIsUInt)) {
            return MType.float(wa >= wb ? wa : wb);
        }

        return null;
    }

    public function makeConstraints(expr: MExpr, scope: MTypingScope): Void {
        switch expr.kind {
            case EBinop(e0, e1, _):
                var r = MType.mono();
                unify(e0.type, r);
                unify(e1.type, r);
                unify(expr.type, r);

            case EBlock(list):
                unify(expr.type, list.last().type);

            case EConst(CIdent(name)): null;
            case EConst(_): null;

            case _: trace('unhandeled $expr'); null;
        }

        makeConstraintsIter(expr, scope.copy());
    }

    public function makeConstraintsIter(expr: MExpr, scope: MTypingScope): Void {
        MExprTools.iterate(expr, makeConstraints.bind(_, scope));
    }


    public function applySubst(expr: MExpr): Void {
        expr.type = subst.apply(expr.type);
    }

}