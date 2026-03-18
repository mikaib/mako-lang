package typing;

class MType {

    private var _concrete: MConcreteType;

    public static function mono(): MType {
        return new MType(MConcreteType.createMono());
    }

    public static function make(x: String): MType {
        return new MType(MConcreteType.createConcrete(x));
    }

    private function new(c: MConcreteType) {
        _concrete = c;
    }

    public function setRef(c: MConcreteType): Void {
        _concrete = c;
    }

    public function setVal(c: MConcreteType): Void {
        _concrete.set(c);
    }

    public function isMono(): Bool {
        return !_concrete.defined;
    }

    public function width(): Int {
        return _concrete.width();
    }

    public function concrete(): MConcreteType {
        return _concrete;
    }

    public function toString() {
        return _concrete.toString();
    }

}
