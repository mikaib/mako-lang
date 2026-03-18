package typing;

@:structInit
class MConcreteType {

    private static var _globalID: Int = 0;

    public var name: String = "";
    public var id: Int = _globalID++;
    public var params: Array<MType> = [];
    public var defined: Bool = false;

    public static function createMono(): MConcreteType {
        return {};
    }

    public static function createConcrete(name: String): MConcreteType {
        var c: MConcreteType = {};
        c.name = name;
        c.defined = true;

        return c;
    }

    private function new() {}

    public function set(c: MConcreteType) {
        if (!c.defined) {
            return;
        }

        this.name = c.name;
        this.params = c.params.copy();
        this.defined = true;
    }

    public function width(): Int {
        return switch name {
            case "void": 0;
            case "i8", "u8", "bool": 8;
            case "i16", "u16", "f16": 16;
            case "i32", "u32", "f32": 32;
            case "i64", "u64", "f64": 64;
            case _: 0;
        }
    }

    public function toString() {
        return defined ? 'TType($name, [${params.map(Std.string).join(", ")}])' : 'TMono($id)';
    }

}
