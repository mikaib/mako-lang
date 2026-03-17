package lexing;

import core.MPositionRange;
import lexing.MTokenKind.MTokenUtil;

@:structInit
class MToken {
    public var kind: MTokenKind;
    public var pos:  MPositionRange;

    public function toString() {
        return '\nMToken(t=${MTokenUtil.tokenKindToString(kind)}, p=${pos})';
    }
}
