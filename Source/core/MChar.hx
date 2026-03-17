package core;

@:forwardStatics
@:forward
abstract MChar(Int) from Int to Int {
    
    public function toUpperCase(): MChar {
        return (abstract : String).toUpperCase();
    }

    public function toLowerCase(): MChar {
        return (abstract : String).toLowerCase();
    }

    @:from
    public static function fromString(x: String) {
        return x.charCodeAt(0);
    }

    @:to
    public function toString() {
        return String.fromCharCode(this);
    }

}