package typing;

class MType {

    private var _concrete: MConcreteType;

    public static var TMono(get, never): MType;
    private static inline function get_TMono(): MType {
        return new MType(MConcreteType.createMono());
    }

    public static var TF32(get, never): MType;
    private static inline function get_TF32(): MType {
        return new MType(MConcreteType.createConcrete("f32"));
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

    public function concrete(): MConcreteType {
        return _concrete;
    }

    public function toString() {
        return _concrete.toString();
    }

}
