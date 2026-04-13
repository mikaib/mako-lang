package ir.impl;

import typing.MType;

class MIRC {

    private var _program: MIRProgram;

    public function new(program: MIRProgram) {
        _program = program;
    }

    public function emitFunction(f: MIRFunction): String {
        var buf = new StringBuf();
        buf.add(emitType(f.returnType) + " " + f.name + "(");
        buf.add(f.parameters.map(p -> emitType(p.type) + " " + emitOperand(Register(p.register)) + " /* " + p.name + " */").join(", "));
        buf.add(") {\n");

        for (inst in f.instructions) {
            var code = emitInstruction(inst);
            if (code != null) {
                buf.add("    " + code + "\n");
            }
        }

        buf.add("}\n");

        return buf.toString();
    }

    public function emitModule(): String {
        var buf = new StringBuf();

        for (func in _program) {
            buf.add(emitFunction(func));
        }

        return buf.toString();
    }

    public function emitOperand(op: MIROperand): String {
        switch op {
            case Register(x):
                return 'reg_$x';

            case Function(x):
                return x;

            case Type(x):
                return emitType(x);

            case Int(x):
                return Std.string(x);

            case Float(x):
                return Std.string(x);

            case String(x):
                return '"$x"';
        }
    }

    public function emitType(t: MType): String {
        var c = t.concrete;
        if (!c.defined) {
            return 'void /* mono #${c.id} */';
        }

        if (c.isBool()) {
            return 'bool';
        }

        if (c.isInt()) {
            return 'int${c.width()}_t';
        }

        if (c.isUInt()) {
            return 'uint${c.width()}_t';
        }

        if (c.isFloat()) {
            switch c.width() {
                case 16: return 'float /* f16 */'; // TODO: using float for now...
                case 32: return 'float';
                case 64: return 'double';
                case _: throw 'unsupported float width: ${c.width()}';
            }
        }

        if (c.isVoid()) {
            return 'void';
        }

        throw 'unsupported type: ${c.name}';
    }

    public function emitInstruction(inst: MIRInstruction): String {
        var line = switch inst.kind {
            case Add:
                var left = emitOperand(inst.data[0]);
                var right = emitOperand(inst.data[1]);
                var type = emitType(inst.result.type);
                var result = emitOperand(Register(inst.result.register));
                '$type $result = $left + $right';

            case Cast:
                var value = emitOperand(inst.data[0]);
                var type = emitOperand(inst.data[1]);
                var result = emitOperand(Register(inst.result.register));
                '$type $result = ($type)$value';

            case Return:
                var value = emitOperand(inst.data[0]);
                'return $value';

            case Call:
                var func = emitOperand(inst.data[0]);
                var args = inst.data.slice(1).map(emitOperand).join(", ");
                var type = emitType(inst.result.type);
                var result = emitOperand(Register(inst.result.register));
                '$type $result = $func($args)';

            case _: null;
        }

        return StringTools.rpad('$line;', ' ', 80) + '/* ${inst.result.register != -1 ? "$" + '${inst.result.register}: ${inst.result.type.toString()} = ' : ''}${inst.kind} ${inst.data.join(' ')} */';
    }

}
