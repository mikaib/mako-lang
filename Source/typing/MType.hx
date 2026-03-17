package typing;

class MType {

    private var _concrete: MConcreteType;

    public static var TMono(get, never): MType;
    public static inline function get_TMono(): MType {
        return new MType({});
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

    public function toString() {
        return _concrete.toString();
    }

}
