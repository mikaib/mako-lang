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

    public static function intoOperationAST(input: ArrayView<MToken>, leftAST: MOption<MExpr>, lastOperator: MOption<MTokenOperator>, context: Context, parser: MParser): ParserFlowControl {
        var firstToken = input.peek();
        if (leftAST.isNone() && !Std.isOfType(firstToken, TTokenOperator)) {
            return PParseError;
        }
        return PParseError;
    }

    /*
    public static function intoOperationASTOLD(input: ArrayView<MToken>, leftAST: MOption<MExpr>, context: Context, parser: MParser): ParserFlowControl {
        var firstToken = input[0];
        if (leftAST == None && !Std.isOfType(input.peek(), TTokenOperator)) {
            var expr = parser.parseNextExpr();
            switch (expr) {
                case PReturnSome(ast):
                    leftAST = Some(ast);
                case _:
            }
        }

        var firstOperator = switch (input.next()) {
            case TTokenOperator(o): o;
            default: return PParseError;
        }

        if (firstOperator.match(TTokenOperator(MTokenOperator.OIncrement)) ||
            firstOperator.match(TTokenOperator(MTokenOperator.ODecrement))) {
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
                if (input[0].kind.match(TSemiColon) || input[0].kind.match(TParentClose)) {
                    return PReturnSome(expr);
                }

                return intoOperationAST(input, Some(expr), context, parser);
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

        var right = input.subslice(0, readIndex);
        input.consume(readIndex);
        var lastToken = right[right.length - 1];
        parser.push_stack(right);
        var expr = parser.intoMExpr(); // new MParser(right, context).intoMExpr();
        parser.pop_stack();
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
            return intoOperationAST(input, Some(expr), context, parser);
        }
        return PReturnSome(expr);
    }
     */
}
