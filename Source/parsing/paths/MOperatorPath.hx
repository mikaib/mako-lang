package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import core.MOption;
import core.MOptionKind;
import core.MBinop;
import core.MUnop;
import haxe.Exception;
import error.MErrorKind;

class MOperatorPath {
    private static function getPrecedance(op: MTokenOperator): Int {
        switch(op) {
            case OIncrement, ODecrement, ONot:
                return 1;
            case OMultiply, ODivide:
                return 2;
            case OPlus, OMinus:
                return 3;
            case OLogicalAnd:
                return 4;
            case OLogicalOr:
                return 5;
            case ONotEaqual, OEqual, OGreatherThen, OGreaterThenEqualTo, OLessThen, OLessThenEqualTo, OAddAssign, OSubtractAssign, OMultiplyAssign, ODivideAssign, OOrAssign, OAndAssign, OXorAssign:
                return 6;
            default:
                throw new Exception('Internal compiler error: Unexpected operator: $op');
        }
    }

    private static function makeExpressionBlock(input: ArrayView<MToken>, context: Context): ParserFlowControl {
        var index = 0;
        var run = true;
        var parentDepth = 0;
        var blockDepth = 0;
        while (input.length > index && run) {
            switch (input[index].kind) {
                case MTokenKind.TTokenOperator(_):
                    if (parentDepth == 0 && blockDepth == 0) {
                        run = false;
                    }
                    else {
                        index++;
                    }
                case TBraceClose:
                    blockDepth -= 1;
                    index++;
                case TBraceOpen:
                    blockDepth += 1;
                    index++;
                case TParentOpen:
                    parentDepth += 1;
                    index++;
                case TParentClose:
                    parentDepth -= 1;
                    index++;
                default:
                    index++;
            }

            if (!run) {
                break;
            }
        }

        var block = input.subslice(0, index);
        input.consume(index);
        var expr = new MParser(block, context).intoMExpr();
        if (expr.isNone()) {
            return PParseError;
        }

        return PReturnSome(expr.unwrap());
    }

    private static function intoBinOp(op: MTokenOperator): MOption<MBinop> {
        final table = [
            MTokenOperator.OPlus => MBinop.Add,
            MTokenOperator.OMinus => MBinop.Sub,
            MTokenOperator.OMultiply => MBinop.Mul,
            MTokenOperator.ODivide => MBinop.Div,
            MTokenOperator.ONotEaqual => MBinop.NotEq,
            MTokenOperator.OEqual => MBinop.Eq,
            MTokenOperator.OGreatherThen => MBinop.GreaterThen,
            MTokenOperator.OGreaterThenEqualTo => MBinop.GreaterThenEqualTo,
            MTokenOperator.OLessThen => MBinop.LessThen,
            MTokenOperator.OLessThenEqualTo => MBinop.LessThenEqualTo,
            MTokenOperator.OAddAssign => MBinop.AssignOp(MBinop.Add),
            MTokenOperator.OSubtractAssign => MBinop.AssignOp(MBinop.Sub),
            MTokenOperator.OMultiplyAssign => MBinop.AssignOp(MBinop.Mul),
            MTokenOperator.ODivideAssign => MBinop.AssignOp(MBinop.Div),
            MTokenOperator.OOrAssign => MBinop.AssignOp(MBinop.BitOr),
            MTokenOperator.OAndAssign => MBinop.AssignOp(MBinop.BitAnd),
            MTokenOperator.OXorAssign => MBinop.AssignOp(MBinop.BitXor),
        ];

        final result = table[op];
        if (result == null) {
            return None;
        }
        return Some(result);
    }

    private static function intoUnOp(op: MTokenOperator): MOption<MUnop> {
        if (op.match(MTokenOperator.OIncrement)) {
            return Some(Inc);
        }
        else if (op.match(MTokenOperator.ODecrement)) {
            return Some(Dec);
        }
        else if (op.match(MTokenOperator.ONot)) {
            return Some(Neg);
        }
        else if (op.match(MTokenOperator.OMinus)) {
            return Some(Min);
        }
        return None;
    }

    public static function intoOperationAST(input: ArrayView<MToken>, leftAST: MOption<MExpr>, context: Context): ParserFlowControl {
        if (leftAST == None) {
            var expr = makeExpressionBlock(input, context);
            switch(expr) {
                case PReturnSome(ast):
                    leftAST = Some(ast);
                default:
                    leftAST;
            }
        }
        var firstToken = input[0];
        var firstTokenKind = firstToken?.kind;
        var firstOperator = switch (firstTokenKind) {
            case (TTokenOperator(o)): o;
            default: return PParseError;
        }
        input.consume(1);

        if (firstToken.kind.match(TTokenOperator(MTokenOperator.OIncrement)) ||
            firstToken.kind.match(TTokenOperator(MTokenOperator.ODecrement))) {
            if (leftAST.hasValue()) {
                var unop = intoUnOp(firstOperator);
                if (unop.isNone()) {
                    context.emitError(MErrorKind.ParserExpectedUnaryOperator, input.intoArray());
                    return PParseError;
                }
                var expr: MExpr = {
                    kind: MExprKind.EUnop(leftAST.unwrap(), unop.unwrap(), false),
                    pos: {
                        path: firstToken.pos.path,
                        min: firstToken.pos.min,
                        max: firstToken.pos.max,
                    }
                };
                if (input.length > 0) {
                    return intoOperationAST(input, Some(expr), context);
                }
                return PReturnSome(expr);
            }
        }

        var depth = 0;
        var readIndex = 0;
        while (input.length > readIndex) {
            var op: MOption<MTokenOperator> = switch (input[readIndex].kind) {
                case TParentOpen: depth++; None;
                case TParentClose: depth--; None;
                case TTokenOperator(op): Some(op);
                default: None;
            }

            if (op.hasValue() && getPrecedance(op.unwrap()) >= getPrecedance(firstOperator) && depth == 0) {
                break;
            }

            readIndex++;
        }

        if (depth != 0) {
            context.emitError(MErrorKind.ParserMissingClosingParenthesis, input.intoArray());
            return PParseError;
        }
        if (readIndex == 0) {
            throw new Exception("Triggered parsing error in the operatorPath"); //TODO: Create
        }

        var right = input.subslice(0, readIndex);
        input.consume(readIndex);
        var lastToken = right[right.length - 1];
        var expr = new MParser(right, context).intoMExpr();
        if (expr.isNone()) {
            return PParseError;
        }
        var rExpr = expr.unwrap();
        var op = switch (leftAST) {
            case Some(lExpr):
                var binop = intoBinOp(firstOperator);
                if (binop.isNone()) {
                    context.emitError(MErrorKind.ParserExpectedBinaryOperator, input.intoArray());
                    return PParseError;
                }
                MExprKind.EBinop(lExpr, rExpr, binop.unwrap());
            case None:
                var unop = intoUnOp(firstOperator);
                if (unop.isNone()) {
                    context.emitError(MErrorKind.ParserExpectedUnaryOperator, input.intoArray());
                    return PParseError;
                }
                MExprKind.EUnop(rExpr, unop.unwrap(), true);
        }
        var expr: MExpr = {
            kind: op,
            pos: {
                path: firstToken.pos.path,
                min: firstToken.pos.min,
                max: lastToken.pos.max,
            }
        };

        if (input.length > 0) {
            return intoOperationAST(input, Some(expr), context);
        }
        return PReturnSome(expr);
    }

    // IsOperator returns true when an input ArrayView contains operators at a depth of 0
    // e.g.
    // 1 + 1 is true
    // (1 + 1) is false, paranthesis make it a depth of one
    // (1 + 1) - 2 is also true, there are operators at a depth of 1 and 0.
    public static function IsOperator(input: ArrayView<MToken>): Bool {
        var index = 0;
        var parentDepth = 0;
        var blockDepth = 0;
        while (input.length > index) {
            switch (input[index].kind) {
                case MTokenKind.TTokenOperator(_):
                    if (parentDepth == 0 && blockDepth == 0) {
                        return true;
                    }
                    else {
                        index++;
                    }
                case TBraceClose:
                    blockDepth -= 1;
                    index++;
                case TBraceOpen:
                    blockDepth += 1;
                    index++;
                case TParentOpen:
                    parentDepth += 1;
                    index++;
                case TParentClose:
                    parentDepth -= 1;
                    index++;
                default:
                    index++;
            }
        }
        return false;
    }
}
