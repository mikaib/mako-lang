package core;

@:structInit
class MPosition {

    public var path: String;
    public var line: Int;
    public var column: Int;

    public function toString() {
        return 'MPosition(path=${path} pos=${line}:${column})';
    }

}
