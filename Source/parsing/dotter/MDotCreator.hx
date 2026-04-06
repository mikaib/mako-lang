package parsing.dotter;
import sys.io.File;
import parsing.MExprList;
import parsing.MExpr;
import parsing.MExprKind;
import haxe.exceptions.NotImplementedException;
import haxe.ds.HashMap;

typedef MExprDotData = {
    label: String,
    children: Array<MExpr>,
}

class MDotCreator {

    var lastIdentifier = 0;
    var labelNames: Map<Int, String> = new Map<Int, String>();
    public function new() {}

    public function getMExprData(mExpr: MExprKind): MExprDotData {
        switch (mExpr) {
            case EBinop(left, right, op):
                return {
                    label: 'BinOp ${op}',
                    children: [left, right],
                };
            case EUnop(expr, op):
                return {
                    label: 'UnOp ${op}',
                    children: [expr],
                };
            case EArrayAccess(expr, index):
                throw new NotImplementedException();
            case EArrayDecl(values):
                throw new NotImplementedException();
            case ECall(expr, args):
                throw new NotImplementedException();
            case EParenthesis(expr):
                throw new NotImplementedException();
            case EBlock(exprs):
                var expressions = exprs.map(e -> e);
                return {
                    label: 'BLOCK',
                    children: expressions,
                };
            case EWhile(econd, ebody):
                throw new NotImplementedException();
            case EReturn(expr):
                return {
                    label: "Return",
                    children: [expr],
                };
            case EFunction(f):
                return {
                    label: 'func ${f.name} (${f.args}): ${f.returnType}',
                    children: [f.expr],
                };
            case EIf(econd, eif, eelse):
                var expressions = [econd, eif];
                if (eelse.hasValue()) {
                    expressions.push(eelse.unwrap());
                }
                return {
                    label: 'if',
                    children: expressions,
                };
            case EVars(decl):
                return {
                    label: '${decl.access} ${decl.const == true ? "const" : ""} var ${decl.names}: ${decl.type}',
                    children: [decl.expr],
                };
            case EConst(const):
                return {
                    label: 'const: ${const}',
                    children: [],
                };
            case EBreak:
                throw new NotImplementedException();
            case EContinue:
                throw new NotImplementedException();
        }
    }

    private function makeDot(mExpr: MExpr, bindTo: String): String {
        var exprData = getMExprData(mExpr.kind);
        var id = lastIdentifier++;
        var returnString = "";
        for (expr in exprData.children) {
            returnString += makeDot(expr, '${id}');
        }
        labelNames.set(id, exprData.label);
        return returnString + '${bindTo} -> ${id};\n';
    }

    public function fromAST(AST: MExprList) {
        var dot = AST.map(e -> makeDot(e, "ROOT"));
        var Start:String = "digraph A {\n";
        var End:String = "}\n";
        var filePath:String = "output.txt";

        //Clear file
        var file = sys.io.File.write(filePath, false);
        file.close();

        var file = File.append(filePath, false);
        file.writeString(Start);
        for(s in dot) {
            file.writeString(s);
        }
        for (key => value in labelNames) {
            file.writeString('$key[label="$value"]\n');
            trace('Key: $key, Value: $value');
        }
        file.writeString(End);
        file.close();
    }
}