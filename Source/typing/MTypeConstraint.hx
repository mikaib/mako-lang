package typing;

@:structInit
class MTypeConstraint {

    public var from: MType;
    public var to: MType;

    public function toString() {
        return 'MTypeConstraint(${from} ~ ${to})';
    }

}
