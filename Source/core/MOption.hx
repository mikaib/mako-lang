package core;

abstract MOption<T>(MOptionKind<T>) from MOptionKind<T> to MOptionKind<T> {

    public function unwrap(): T {
        return switch this {
            case Some(r): r;
            case None: throw "Option is None in unwrap"; null;
        }
    }

    public function hasValue(): Bool {
        return this != None;
    }

}