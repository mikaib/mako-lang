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
import haxe.Exception;

class MOperatorPath {
    private static function getPrecedance(op: MTokenOperator):Null<Int> {
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
            case OEqual, ONotEaqual:
                return 6;
            case OLessThen, OGreatherThen:
                return 7;
            default:
                throw new Exception('Unexpected operator: $op');
        }
    }

    private static function makeExpressionBlock(input: ArrayView<MToken>): ParserFlowControl {
        var index = 0;
        var run = true;
        while (input.length - 1 > index && run) {
            switch (input[index].kind) {
                case MTokenKind.TTokenOperator(_):
                    run = false;
                default:
                    index++;
            }

            if (!run) {
                break;
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
        throw new Exception('Unexpected bin operator: $op');
    }

    private static function intoUnOp(op: MTokenOperator, post: Bool):Null<MUnop> {
        if (Type.enumEq(op, MTokenOperator.OIncrement)) {
            if (post) {
                return MUnop.PostInc;
            }
            return MUnop.PreInc;
        }
        else if (Type.enumEq(op, MTokenOperator.ODecrement)) {
            if (post) {
                return MUnop.PostDec;
            }
            return MUnop.PreDec;
        }
        else if (Type.enumEq(op, MTokenOperator.ONot)) {
            return MUnop.Neg;
        }
        else if (Type.enumEq(op, MTokenOperator.OMinus)) {
            return MUnop.Min;
        }
        throw new Exception('Unexpected unop operator: $op');
    }

    private static function makeOperationAST(input: ArrayView<MToken>, leftAST: MOption<MExpr>): ParserFlowControl {
        if (leftAST == None) {
            trace(input.map(t -> 't: ${t.kind}'));
            var expr = makeExpressionBlock(input);
            switch(expr) {
                case PReturnSome(ast):
                    leftAST = Some(ast);
                default:
                    leftAST;
            }
        }
        var firstToken = input[0];
        trace('EXPR: ${leftAST}, TOKEN: ${firstToken}');
        var firstTokenKind = firstToken?.kind;
        var firstOperator = switch (firstTokenKind) {
            case (TTokenOperator(o)):
                o;
            default:
                return PNotParsed;
        }
        input.consume(1);

        if (Type.enumEq(firstToken.kind, TTokenOperator(MTokenOperator.OIncrement)) ||
            Type.enumEq(firstToken.kind, TTokenOperator(MTokenOperator.ODecrement))) {
            if (leftAST.hasValue()) {
                var unop = MExprKind.EUnop(leftAST.unwrap(), intoUnOp(firstOperator, true));
                var expr: MExpr = {
                    kind: unop,
                    pos: {
                        path: firstToken.pos.path,
                        min: firstToken.pos.min,
                        max: firstToken.pos.max,
                    }
                };
                if (input.length > 0) {
                    return makeOperationAST(input, Some(expr));
                }
                return PReturnSome(expr);
            }
        }

        var depth = 0;
        var readIndex = 0;
        while (input.length > readIndex) {
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

            if (op != null && getPrecedance(op) >= getPrecedance(firstOperator) && depth == 0) {
                break;
            }

            readIndex++;
        }

        if (readIndex == 0) {
            return PNotParsed;
        }

        var right = input.subslice(0, readIndex);
        input.consume(readIndex);
        var lastToken = right[right.length - 1];
        var rightExpression = tryIntoEBlock(right);
        var rExpr = switch (rightExpression) {
            case PReturnSome(r):
                r;
            case PReturnEaten:
                return PReturnEaten;
            case PNotParsed:
                return PNotParsed;
        }
        var op = switch (leftAST) {
            case Some(lExpr):
                MExprKind.EBinop(lExpr, rExpr, intoBinOp(firstOperator));
            case None:
                MExprKind.EUnop(rExpr, intoUnOp(firstOperator, false));
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
        switch (expr) {
            case PReturnSome(_):
                input.consume(readIndex);
            default:
        }
        return expr;
    }
}

