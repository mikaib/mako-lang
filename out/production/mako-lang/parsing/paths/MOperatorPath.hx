package parsing.paths;
import lexing.MToken;
import core.MArrayView.ArrayView;
import parsing.MParser.ParserFlowControl;
import lexing.MTokenKind;
import parsing.paths.MBlockPath.tryIntoEBlock;
import core.MOption;
import core.MOptionKind;
import core.MBinop;
import core.MUnop;

class MOperatorPath {
    private static function getPrecedance(op: MTokenOperator):Null<Int> {
        switch(op) {
            case OMultiply, ODivide:
                return 1;
            case OPlus, OMinus:
                return 2;
            case OLogicalAnd:
                return 3;
            case OLogicalOr:
                return 4;
            case OEqual, ONotEaqual:
                return 5;
            case OLessThen, OGreatherThen:
                return 6;
            default:
                return null;
        }
    }

    private static function makeExpressionBlock(input: ArrayView<MToken>): ParserFlowControl {
        var index = 0;
        while (input.length > 0) {
            if (!Std.isOfType(input[index].kind, MTokenKind.TTokenOperator)) {
                index++;
            }
        }

        var block = input.subslice(0, index);
        input.consume(index);
        return tryIntoEBlock(block);
    }

    private static function intoBinOp(op: MTokenOperator): Null<MBinop> {
        if (Type.enumEq(op, MTokenOperator.OPlus)) {
            return MBinop.Add;
        }
        else if (Type.enumEq(op, MTokenOperator.OMinus)) {
            return MBinop.Sub;
        }
        else if (Type.enumEq(op, MTokenOperator.OMultiply)) {
            return MBinop.Mul;
        }
        else if (Type.enumEq(op, MTokenOperator.ODivide)) {
            return MBinop.Divide;
        }
        return null;
    }

    private static function intoUnOp(op: MTokenOperator):Null<MUnop> {
        if (Type.enumEq(op, MTokenOperator.OIncrement)) {
            return MUnop.Inc;
        }
        else if (Type.enumEq(op, MTokenOperator.ODecrement)) {
            return MUnop.Dec;
        }
        else if (Type.enumEq(op, MTokenOperator.ONot)) {
            return MUnop.Neg;
        }
        else if (Type.enumEq(op, MTokenOperator.OMinus)) {
            return MUnop.Min;
        }
        return null;
    }

    private static function makeOperationAST(input: ArrayView<MToken>, leftAST: MOption<MExpr>): ParserFlowControl {
        if (leftAST == null) {
            var expr = makeExpressionBlock(input);
            switch(expr) {
                case PReturnSome(ast):
                    leftAST = Some(ast);
                case PNotParsed:
                    leftAST;
            }
        }
        var firstToken = input[0];
        var firstTokenKind = firstToken?.kind;
        var firstOperator = switch (firstTokenKind) {
            case (TTokenOperator(o)):
                o;
            default:
                return PNotParsed;
        }
        input.consume(1);
        var depth = 0;
        var readIndex = 0;
        while (input.length > 0) {
            if (Type.enumEq(input[readIndex].kind, TParantOpen)) {
                depth++;
            }
            else if (Type.enumEq(input[readIndex].kind, TParantClose)) {
                depth--;
            }

            var op = switch (input[readIndex].kind) {
                case TTokenOperator(op): op;
                default: null;
            }

            if (op != null && getPrecedance(op) > getPrecedance(firstOperator)) {
                break;
            }

            readIndex++;
        }

        var right = input.subslice(0, readIndex);
        input.consume(readIndex);
        var lastToken = right[right.length];
        var rightExpression = tryIntoEBlock(right);
        var rExpr = switch (rightExpression) {
            case PReturnSome(r):
                r;
            case PNotParsed:
                return PNotParsed;
        }
        var op = switch (leftAST) {
            case Some(lExpr):
                MExprKind.EBinop(lExpr, rExpr, intoBinOp(firstOperator));
            case None:
                MExprKind.EUnop(rExpr, intoUnOp(firstOperator));
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
            return makeOperationAST(input, Some(expr));
        }
        return PReturnSome(expr);
    }

    public static function tryIntoEOperation(input: ArrayView<MToken>): ParserFlowControl {
        var readIndex = 0;
        var depth = 0;
        while (readIndex < input.length) {
            var kind = input[readIndex].kind;
            if (kind == TBraceOpen) depth++;
            else if (kind == TBraceClose) depth--;
            else if (kind == TSemiColon && depth == 0) break;

            readIndex++;
        }

        var operationBlock = input.subslice(0, readIndex);
        var expr = makeOperationAST(operationBlock, None);
        if (!Std.isOfType(expr, PReturnSome)) {
            input.consume(readIndex);
        }
        return expr;

        /*
        var depth = 0;
        var leftConst = tryIntoEConst(input);
        var operator = input[0].kind;
        var precedance = switch (operator) {
            case (TTokenOperator(o)):
                getPrecedance(o);
            default:
                return PNotParsed;
        }

        while (input.length > 0) {
            var eConst = tryIntoEConst(input);
            var precedance = 0;
            switch (input[0].kind) {
                case (TTokenOperator(o)): break;
                case (TParantOpen): depth++;
                case (TParantClose): depth--;
            }
        }*/
        // 1 + 2 * 3 + 4 * 5
        // plus(1, plus(mul(2, 3), mul(4, 5)))
        // 1 + .............
        // 2 * 3 + 4 * 5
        // plus(mul(2, 3), mul(4, 5))

        // 1 * 2 * 3 + 4 * 5
        // plus(mul(mul(1, 2), 3), mul(4, 5))
        // 1 * .............
        // 2 * 3 + 4 * 5
        // plus(mul(2, 3), mul(4, 5))
        // 2 * 3 + 4 * 5 + 1

        //-----------------
        // a = 1 + 2 && 3 + 4 * 5
        // plus(1, plus(and(2, 3), mul(4, 5)))

        // plus(plus(1, and(2, 3)), mul(4, 5))
        //-----------------

        //-----------------
        // a = 1 * 2 + 3 && 4 + 5
        // plus(plus(mul(1, 2), and(3, 4)), 5)
        //-----------------

        //-----------------
        // a = 1 + 2 && 3 && 4 + 5 * 6
        // plus(plus(1, and(and(2, 3), 4)), mul(5, 6))

        // 1 + and(2, 3) + 4 * 5
        // plus(1, and(2, 3)) + 4 * 5
        // plus(LEFT, parse(4 * 5))
        // plus(plus(1, and(2, 3)), mul(4, 5))

        // plus(plus(1, and(2, 3)), mul(4, 5))
        //-----------------

        //-----------------
        // a = 1 * 2 + 3 * 4
        // plus(mul(1, 2), mul(3, 4))

        // mul(1, 2)
        // plus(LEFT, parse(3 * 4))
        // mul(3, 4)

        // plus(mul(1, 2), mul(3, 4))
        //-----------------

        //-----------------
        // a = 1 + 3 + 2 && 3 + 4 * 5
        // and(plus(plus(1, 3), 2), plus(3, mul(4, 5)))

        // plus(1, 3) + 2 && 3 + 4 * 5
        // plus(LEFT, 2) && 3 + 4 * 5
        // and(LEFT, parse(3 + 4 * 5))
        // and(plus(plus(1, 3), 2), plus(3, parse(4 * 5)))
        // and(plus(plus(1, 3), 2), plus(3, mul(4, 5)))

        // plus(1, 2) && 3 + 4 * 5
        // and(LEFT, parse(3 + 4 * 5))
        // 3 + 4 * 5
        // 3 + mul(4, 5)
        // plus(3, mul(4, 5))

        // and(plus(1, 2) && mul(plus(3, 4), 5))
        //-----------------
    }
}

