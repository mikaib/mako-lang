package typing;

import parsing.MExprList;
import parsing.MExpr;
import core.MExprTools;
import error.MErrorKind;
import core.MOptionKind;
import parsing.MExprKind;

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
        for (e in _root) makeConstraints(e, {});
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
                makeConstraints(e0, scope);
                makeConstraints(e1, scope);
                unify(expr.type, e0.type);
                unify(expr.type, e1.type);

            case EBlock(list):
                var blockScope = scope.copy();
                for (e in list) makeConstraints(e, blockScope);
                unify(expr.type, list.last().type);

            case EReturn(e):
                makeConstraints(e, scope);

                var f = scope.getCurrentFunction();
                if (f.hasValue()) unify(expr.type, f.unwrap().returnType);
                unify(expr.type, e.type);

            case EVars(decls):
                unify(decls[decls.length - 1].type, expr.type); // last decl is the block's type

                for (d in decls) {
                    scope.defineVariable(d);
                    if (d.expr != null) {
                        makeConstraints(d.expr, scope);
                        unify(d.type, d.expr.type);
                    }
                }

            case EConst(CIdent(name)):
                switch scope.findVariable(name) {
                    case Some(decl): unify(expr.type, decl.type);
                    case None: _context.emitError(MErrorKind.TyperInvalidScope, [name, expr]);
                }

            case ECast(_, type):
                unify(expr.type, type);

            case EFunction(f):
                var local = scope.copy();
                local.setCurrentFunction(f);

                for (a in f.args) local.defineVariable({
                    name: a.name,
                    type: a.type
                });

                if (f.expr != null) makeConstraints(f.expr, local);
                unify(expr.type, MType.callable(f.args.map(a -> a.type), f.returnType));

            case EConst(_):
                // todo: const

            case _:
                trace('unhandled $expr');
        }
    }

    public function applySubst(expr: MExpr): Void {
        expr.type = subst.apply(expr.type);

        switch expr.kind {
            case EVars(decls):
                for (d in decls) {
                    d.type = subst.apply(d.type);
                    if (d.expr != null && needsCast(d.expr.type, d.type)) {
                        d.expr = wrapCast(d.expr, d.type);
                    }
                }

            case EBinop(e0, e1, op):
                var wider = implicitCast(e0.type, e1.type);
                if (wider == null) {
                    _context.emitError(MErrorKind.TyperUnificationFailed, [e0.type, e1.type]);
                    return;
                }

                expr.type = wider;

                if (needsCast(e0.type, wider)) {
                    expr.kind = EBinop(wrapCast(e0, wider), e1, op);
                }

                if (needsCast(e1.type, wider)) {
                    expr.kind = EBinop(e0, wrapCast(e1, wider), op);
                }

            case _: null;
        }
    }

    private function wrapCast(expr: MExpr, to: MType): MExpr {
        return { pos: expr.pos, kind: ECast(expr, to), type: to };
    }

    private function needsCast(from: MType, to: MType): Bool {
        if (from.isMono() || to.isMono()) return false;
        return from.concrete.name != to.concrete.name;
    }

}