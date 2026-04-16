package ir.gen;
import parsing.MExprList;
import parsing.MExpr;
import parsing.MExprKind;
import core.MBinop;
import core.MFuncDecl;
import typing.MType;

class MIRGenerator {

    private var _ast: MExprList;
    private var _out: MIRProgram;

    public function new(ast: MExprList) {
        _ast = ast;
        _out = [];
    }

    public function emit(kind: MIRInstructionKind, data: Array<MIROperand>, result: MIRResult, scope: MIRGeneratorScope): MIROperand {
        var f = scope.getCurrentFunction();
        if (f == null) {
            trace('expr outside of func!');
            return MIROperand.None;
        }

        f.instructions.push({
            kind: kind,
            data: data,
            result: result
        });

        return result.register != -1 ? MIROperand.Register(result.register) : MIROperand.None;
    }

    public function makeResult(expr: MExpr, scope: MIRGeneratorScope): MIRResult {
        return {
            register: scope.assignRegister(),
            type: expr.type
        };
    }

    public function makeFunction(f: MFuncDecl, scope: MIRGeneratorScope): MIROperand {
        var res = scope.setCurrentFunction(f.name, f.args.map(a -> ({
            name: a.name,
            type: a.type,
            register: scope.assignRegister()
        } : MIRParameter)), f.returnType);

        if (f.expr != null) {
            makeExpr(f.expr, scope);
        }

        _out.push(res);

        return MIROperand.Function(f.name); // TODO: change when we support callables
    }

    public function makeExpr(expr: MExpr, scope: MIRGeneratorScope): MIROperand {
        return switch expr.kind {
            case EFunction(f):
                makeFunction(f, scope);

            case EBinop(e0, e1, MBinop.Add):
                emit(MIRInstructionKind.Add, [makeExpr(e0, scope), makeExpr(e1, scope)], makeResult(expr, scope), scope);

            case ECast(e, type):
                emit(MIRInstructionKind.Cast, [makeExpr(e, scope), MIROperand.Type(type)], makeResult(expr, scope), scope);

            case EReturn(e):
                emit(MIRInstructionKind.Return, [makeExpr(e, scope)], {}, scope);

            case EBlock(exprs):
                exprs.mapAndLast(makeExpr.bind(_, scope.copy())) ?? MIROperand.None;

            case EConst(c):
                switch c {
                    case CInt(i):
                        MIROperand.Int(Std.parseInt(i)); // TODO: check if correct

                    case CFloat(f):
                        MIROperand.Float(Std.parseFloat(f)); // TODO: check if correct

                    case CString(s):
                        MIROperand.String(s);

                    case CBool(b):
                        MIROperand.Bool(b);

                    case CIdent(name):
                        MIROperand.Register(scope.getVariable(name).register);
                }

            case _: trace('Unhandled IRGen ${expr.kind}'); MIROperand.None;
        }
    }

    public function run(): MIRProgram {
        _out = [];

        for (e in _ast) {
            makeExpr(e, {});
        }
        // TODO: impl

        return _out;
    }

}
