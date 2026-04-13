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

    public function isAlphaNumeric(): Bool {
        return  (this >= '0'.code && this <= '9'.code) ||
                (this >= 'A'.code && this <= 'Z'.code) ||
                (this >= 'a'.code && this <= 'z'.code);
    }

    @:from
    public static function fromString(x: String): MChar {
        return x.charCodeAt(0);
    }

    @:to
    public function toString() {
        return String.fromCharCode(this);
    }

}