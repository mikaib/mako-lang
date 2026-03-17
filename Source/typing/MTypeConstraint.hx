package typing;

@:structInit
class MTypeConstraint {

    public var from: MType;
    public var to: MType;
    public var bidirectional: Bool;

    public var flattenedCo: Array<MType> = [];
    public var flattenedEq: Array<MType> = [];

    public function complete(t: MType): Void {
        var c = t.concrete();
        from.setVal(c);
        to.setVal(c);
    }

    public function hasDependency(t: MType) {
        return from == t || to == t;
    }

    public function canSolve(): Bool {
        return flattenedCo.length != 0 || flattenedEq.length != 0;
    }

    public function flatten(many: Array<MTypeConstraint>): Void {
        for (c in many) { // TODO: fix complexity
            switch [hasDependency(c.from), hasDependency(c.to), c.bidirectional] {
                case [_, _, true]:
                    flattenedCo.push(c.to);

                case [true, false, false]:
                    flattenedEq.push(c.to);

                case _: null;
            }
        }
    }

    public function toString() {
        return 'MTypeConstraint(from=$from, to=$to, bi=$bidirectional, eq=$flattenedEq, co=$flattenedCo)';
    }

}
