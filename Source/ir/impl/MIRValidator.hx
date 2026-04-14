package ir.impl;

import typing.MType;
import core.MOption;
import core.MOptionKind;

@:structInit
private class Scope {

    private var _registers: Map<MIRRegister, MType> = new Map();
    private var _functions: Map<String, MIRFunction> = new Map();
    private var _current: MIRFunction = null;
    private var _report: String->Void = (issue) -> {};

    public function markRegister(reg: MIRRegister, type: MType) {
        if (_registers.exists(reg)) {
            _report('register ${reg} already defined before');
        }

        _registers.set(reg, type);
    }

    public function markFunction(name: String, func: MIRFunction) {
        if (_functions.exists(name)) {
            _report('function ${name} already defined before');
        }

        _functions.set(name, func);
    }

    public function validateRegister(reg: MIRRegister, ?type: MType): MOption<MType> {
        if (_registers.exists(reg)) {
            var t = _registers.get(reg);
            if (type != null && !t.concrete.equals(type.concrete)) {
                return None;
            }

            return Some(t);
        }

        return None;
    }

    public function validateFunction(name: String, ?args: Array<MType>): Bool {
        if (!_functions.exists(name)) {
            return false;
        }

        if (args != null) {
            var func = _functions.get(name);
            if (func.parameters.length != args.length) {
                return false;
            }

            for (i in 0...args.length) {
                if (!func.parameters[i].type.concrete.equals(args[i].concrete)) {
                    return false;
                }
            }
        }

        return true;
    }

    public function setReportCallback(callback: String->Void) {
        _report = callback;
    }

    public function setCurrentFunction(func: MIRFunction) {
        _current = func;

        for (param in func.parameters) {
            markRegister(param.register, param.type);
        }
    }

    public function getCurrentFunction(): MIRFunction {
        return _current;
    }

    public function copy(): Scope {
        var newScope: Scope = {
            _registers: _registers.copy(),
            _functions: _functions.copy(),
            _report: _report
        };

        return newScope;
    }

}

class MIRValidator {

    private var _program: MIRProgram;
    private var _issues: Array<String> = [];
    private var _scope: Scope = {};

    public function new(program: MIRProgram) {
        _program = program;
    }

    public function validate(): Array<String> {
        _issues = [];
        _scope = {};
        _scope.setReportCallback(report);

        for (f in _program) {
            var local = _scope.copy();
            local.markFunction(f.name, f);
            local.setCurrentFunction(f);

            validateFunction(f, local);
        }

        return _issues;
    }

    public function validateFunction(f: MIRFunction, scope: Scope) {
        // TODO: register types and params somewhere
        for (inst in f.instructions) {
            validateInstruction(inst, scope);
        }
    }

    public function validateInstruction(inst: MIRInstruction, scope: Scope) {
        switch inst.kind {
            case Add:
                if (inst.data.length != 2) {
                    report('add instruction requires 2 operands, found ${inst.data.length}');
                    return;
                }

                var left = validateOperand(inst.data[0], scope);
                var right = validateOperand(inst.data[1], scope);

                if (!left.concrete.equals(right.concrete)) {
                    report('type mismatch in add instruction: expected ${left}, found ${right}');
                }

                if (inst.result.register == -1) {
                    report('add instruction requires a result register');
                }

                if (!inst.result.type.concrete.equals(left.concrete)) {
                    report('result type mismatch in add instruction: expected ${left}, found ${inst.result.type}');
                }

            case Cast:
                if (inst.data.length != 2) {
                    report('cast instruction requires 2 operands, found ${inst.data.length}');
                    return;
                }

                var value = validateOperand(inst.data[0], scope);
                var type = validateOperand(inst.data[1], scope);

                if (inst.result.register == -1) {
                    report('cast instruction requires a result register');
                }

                if (!inst.result.type.concrete.equals(type.concrete)) {
                    report('result type mismatch in cast instruction: expected ${type}, found ${inst.result.type}');
                }

                if (!validateCast(value, type)) {
                    report('invalid cast from ${value} to ${type}');
                }

            case Return:
                if (inst.data.length != 1) {
                    report('return instruction requires 1 operand, found ${inst.data.length}');
                    return;
                }

                var value = validateOperand(inst.data[0], scope);
                var func = scope.getCurrentFunction();

                if (!value.concrete.equals(func.returnType.concrete)) {
                    report('return type mismatch: expected ${func.returnType}, found ${value}');
                }

                if (inst.result.register != -1) {
                    report('return instruction should not have a result register');
                }

            case Call:
                if (inst.data.length < 1) {
                    report('call instruction requires at least 1 operand, found ${inst.data.length}');
                    return;
                }

                // TODO: impl

            case _:
                trace('unsupported instruction kind: ${inst.kind}, skipping validation');
        }

        if (inst.result.register != -1) {
            scope.markRegister(inst.result.register, inst.result.type);
        }
    }

    public function validateOperand(op: MIROperand, scope: Scope): MType {
        switch op {
            case Register(x):
                var v = scope.validateRegister(x);
                if (!v.hasValue()) {
                    report('undefined register ${x}');
                    return MType.voidType();
                }

                return v.unwrap();

            case Int(_):
                return MType.int(32);

            case Float(_):
                return MType.float(32);

            case String(_):
                return MType.string();

            case Function(name):
                if (!scope.validateFunction(name)) {
                    report('undefined function ${name}');
                    return MType.voidType();
                }

                return MType.voidType(); // TODO: return function type

            case Type(t):
                return t;

            case _:
                trace('unsupported operand kind: ${op}, returning void type');
                return MType.voidType();
        }
    }

    public function validateCast(value: MType, target: MType): Bool {
        return true; // TODO: impl
    }

    public function report(issue: String): Void {
        _issues.push(issue);
    }

}
