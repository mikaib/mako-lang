package typing;

class MType {

    public var concrete: MConcreteType;

    public static function mono(): MType {
        return new MType(MConcreteType.createMono());
    }

    public static function make(name: String, ?params: Array<MType>): MType {
        return new MType(MConcreteType.createConcrete(name, params));
    }

    public static function int(width: Int): MType {
        return switch width {
            case 8, 16, 32, 64: make('i$width');
            case _: throw 'Unsupported int width: $width';
        }
    }

    public static function uint(width: Int): MType {
        return switch width {
            case 8, 16, 32, 64: make('u$width');
            case _: throw 'Unsupported uint width: $width';
        }
    }

    public static function float(width: Int): MType {
        return switch width {
            case 16, 32, 64: make('f$width');
            case _: throw 'Unsupported float width: $width';
        }
    }

    public static function bool(): MType {
        return make("bool");
    }

    public static function voidType(): MType {
        return make("void");
    }

    public static function array(inner: MType): MType {
        return make("arr", [inner]);
    }

    public static function string(): MType {
        return make("str");
    }

    public static function callable(args: Array<MType>, result: MType): MType {
        return new MType(MConcreteType.createCallable(args, result));
    }

    private function new(c: MConcreteType) {
        concrete = c;
    }

    public function id(): Int {
        return concrete.id;
    }

    public function isMono(): Bool {
        return !concrete.defined;
    }

    public function toString() {
        return concrete.toString();
    }

}
