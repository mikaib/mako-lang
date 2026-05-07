package typing;

import core.MVarDecl;
import core.MOption;
import core.MOptionKind;
import core.MFuncDecl;

@:structInit
class MTypingScope {

    public var variables: Array<MVarDecl> = [];
    public var currentFunction: MOption<MFuncDecl> = None;

    public function defineVariable(v: MVarDecl): Void {
        variables.push(v);
    }

    public function findVariable(name: String): MOption<MVarDecl> {
        for (v in variables) {
            if (v.name == name) return Some(v);
        }

        return None;
    }

    public function setCurrentFunction(func: MFuncDecl): Void {
        currentFunction = Some(func);
    }

    public function getCurrentFunction(): MOption<MFuncDecl> {
        return currentFunction;
    }

    public function copy(): MTypingScope {
        return {
            variables: variables.copy(),
            currentFunction: currentFunction
        };
    }

}
