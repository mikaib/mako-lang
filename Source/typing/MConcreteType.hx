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

    public static function createConcrete(name: String, ?params: Array<MType>): MConcreteType {
        var c: MConcreteType = {};
        c.name = name;
        c.defined = true;
        c.params = params ?? [];
        return c;
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
        return defined ? (params.length == 0 ? name : '$name<${params.map(Std.string).join(", ")}>') : 'Mono<#$id>';
    }

    public function isInt(): Bool {
        return switch name {
            case "i8", "i16", "i32", "i64": true;
            case _: false;
        }
    }

    public function isUInt(): Bool {
        return switch name {
            case "u8", "u16", "u32", "u64": true;
            case _: false;
        }
    }

    public function isFloat(): Bool {
        return switch name {
            case "f16", "f32", "f64": true;
            case _: false;
        }
    }

    public function isBool(): Bool {
        return name == "bool";
    }

    public function isNumeric(): Bool {
        return isInt() || isUInt() || isFloat();
    }

    public function isVoid(): Bool {
        return name == "void";
    }

    public function isArray(): Bool {
        return name == "arr";
    }

    public function isArrayOf(elemType: MType): Bool {
        return isArray() && params.length == 1 && params[0].concrete.equals(elemType.concrete);
    }

    public function isString(): Bool {
        return name == "str";
    }

    public function equals(other: MConcreteType): Bool {
        if (defined != other.defined) {
            return false;
        }

        if (!defined) {
            return id == other.id;
        }

        if (name != other.name) {
            return false;
        }

        if (params.length != other.params.length) {
            return false;
        }

        for (i in 0...params.length) {
            if (params[i].toString() != other.params[i].toString()) {
                return false;
            }
        }

        return true;
    }

}