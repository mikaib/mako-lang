package lexing;

import core.MPositionRange;

@:structInit
class MToken {
    public var kind: MTokenKind;
    public var pos:  MPositionRange;
}
