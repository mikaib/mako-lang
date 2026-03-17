package core;

@:structInit
class MPositionRange {

    public var min: MPosition;
    public var max: MPosition;

    public function toString() {
        return 'MPositionRange(${min}, ${max})';
    }

}
