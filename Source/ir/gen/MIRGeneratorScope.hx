package ir.gen;
import typing.MType;

@:structInit
class MIRGeneratorScope {

    private var _regId: Int = 0;
    private var _currFunc: MIRFunction = null;
    private var _variables: Map<String, MIRResult> = new Map();

    public function assignRegister(): MIRRegister {
        return _regId++;
    }

    public function resetRegisters(init: MIRRegister = 0): Void {
        _regId = init;
    }

    public function setCurrentFunction(name: String, params: Array<MIRParameter>, ret: MType): MIRFunction {
        _currFunc = {
            name: name,
            parameters: params,
            returnType: ret
        };

        return _currFunc;
    }

    public function getCurrentFunction(): MIRFunction {
        return _currFunc;
    }

    public function defineVariable(name: String, result: MIRResult): Void {
        _variables.set(name, result);
    }

    public function getVariable(name: String): MIRResult {
        return _variables.get(name);
    }

    public function copy(): MIRGeneratorScope {
        return {
            _regId: _regId,
            _currFunc: _currFunc
        };
    }

}
