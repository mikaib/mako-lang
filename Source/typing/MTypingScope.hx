package typing;

import core.MVarDecl;
import core.MOption;
import core.MOptionKind;

@:structInit
class MTypingScope {

    public var variables: Array<MVarDecl> = [];

    public function defineVariable(v: MVarDecl): Void {
        variables.push(v);
    }

    public function findVariable(name: String): MOption<MVarDecl> {
        for (v in variables) {
            if (v.names.contains(name)) return Some(v);
        }

        return None;
    }

    public function copy(): MTypingScope {
        return {
            variables: variables.copy()
        };
    }

}
