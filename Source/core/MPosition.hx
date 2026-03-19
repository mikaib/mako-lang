package core;

@:structInit
class MPosition {

    public var line: Int;
    public var column: Int;

    public function toString() {
        return 'MPosition(pos=${line}:${column})';
    }

}
