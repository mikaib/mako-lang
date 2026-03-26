package typing;

@:structInit
class MSubstitution {

    private var _map: Map<Int, MType> = [];

    public function bind(id: Int, t: MType): Void {
        _map[id] = t;
    }

    public function lookup(id: Int): MType {
        return _map[id];
    }

    public function apply(t: MType): MType {
        if (!t.isMono()) {
            var params = t.concrete.params.map(p -> apply(p));
            return MType.make(t.concrete.name, params);
        }

        var found = _map[t.id()];
        if (found == null) {
            return t;
        }

        if (found.id() == t.id()) {
            return t;
        }

        var resolved = apply(found);
        bind(t.id(), resolved);

        return resolved;
    }

    public function occurs(id: Int, t: MType): Bool {
        var resolved = apply(t);
        if (resolved.isMono()) {
            return resolved.id() == id;
        }

        return resolved.concrete.params.filter(p -> occurs(id, p)).length != 0;
    }

    public function toString() {
        var entries = [for (k => v in _map) '$k => ${apply(v)}'];
        return 'MSubstitution(${entries.join(", ")})';
    }

}
