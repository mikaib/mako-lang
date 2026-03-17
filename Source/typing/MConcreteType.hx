package typing;

@:structInit
class MConcreteType {

    private static var _globalID: Int = 0;

    public var name: String = "";
    public var id: Int = _globalID++;
    public var params: Array<MType> = [];
    public var defined: Bool = false;

    private function new() {}

    public function set(c: MConcreteType) {
        if (!c.defined) {
            return;
        }

        this.name = c.name;
        this.params = c.params.copy();
        this.defined = true;
    }

    public function toString() {
        return defined ? 'TType($name, [${params.map(Std.string).join(", ")}])' : 'TMono($id)';
    }

}
