package core;

@:structInit
class MPositionRange {

    public var path: String;
    public var min: MPosition;
    public var max: MPosition;

    public function toString() {
        return 'MPositionRange(path=${path}, ${min}, ${max})';
    }

}
