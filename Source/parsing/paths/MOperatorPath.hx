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
    public static function getPrecedence(op: MBinop): Int {
        return switch (op) {
            case Assign, AssignOp(_):
                1;
            case Or:
                2;
            case And:
                3;
            case BitOr:
                4;
            case BitXor:
                5;
            case BitAnd:
                6;
            case Eq, NotEq:
                7;
            case LessThan, GreaterThan, EqualLessThan, EqualGreaterThan:
                8;
            case Add, Sub:
                9;
            case Mul, Div, Mod:
                10;
        };
    }

    private static function intoBinOp(op: MTokenOperator): MOption<MBinop> {
        final table = [
            MTokenOperator.OPlus => MBinop.Add,
            MTokenOperator.OMinus => MBinop.Sub,
            MTokenOperator.OMultiply => MBinop.Mul,
            MTokenOperator.ODivide => MBinop.Div,
            MTokenOperator.ONotEaqual => MBinop.NotEq,
            MTokenOperator.OEqual => MBinop.Eq,
            MTokenOperator.OGreatherThan => MBinop.GreaterThan,
            MTokenOperator.OGreaterThanEqualTo => MBinop.EqualGreaterThan,
            MTokenOperator.OLessThan => MBinop.LessThan,
            MTokenOperator.OLessThanEqualTo => MBinop.EqualLessThan,
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

    public static function isPostfixUnop(token: MTokenKind): Bool {
        switch token {
            case TTokenOperator(op): {
                if (op.match(OIncrement) ||
                    op.match(ODecrement)) {
                    return true;
                }
                return false;
            }
            case _: return false;
        }
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

    public static function intoUnOpExpr(input: ArrayView<MToken>, expr: MOption<MExpr>, context: Context, parser: MParser): ParserFlowControl {
        if (input.peek() == null) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, input.intoArray());
            return PParseError;
        }
        var firstToken = input.next();
        var unop: MOption<MUnop> = switch firstToken.kind {
            case TTokenOperator(op): intoUnOp(op);
            case _: {
                context.emitError(MErrorKind.ParserExpectedUnaryOperator, input.intoArray());
                return PParseError;
            }
        }

        if (unop.isNone()) {
            context.emitError(MErrorKind.ParserExpectedUnaryOperator, input.intoArray());
        }

        var prefix = expr.isNone();

        if (expr.isNone()) {
            var exprControl = parser.parseNextPrimaryExpr();

            expr = Some(switch exprControl {
                case PReturnSome(expr): expr;
                case PParseError: return PParseError;
            });
        }

        return PReturnSome(
            {
                kind: MExprKind.EUnop(expr.unwrap(), unop.unwrap(), prefix),
                pos: {
                    path: firstToken.pos.path,
                    min: firstToken.pos.min,
                    max: input.previous().pos.max,
                }
            }
        );
    }

    // operator precedence parser
    public static function intoBinOpExpr(input: ArrayView<MToken>, leftExpr: MExpr, leftOperation: MOption<MBinop>, context: Context, parser: MParser): ParserFlowControl {
        while(true) {
            if (input.peek() == null) {
                return PReturnSome(leftExpr);
            }
            var firstToken = input.peek();
            var firstOperator = switch input.peek().kind {
                case TTokenOperator(o): o;
                default: return PReturnSome(leftExpr);
            }

            final binOp = intoBinOp(firstOperator);
            if (binOp.isNone()) {
                trace(firstOperator);
                throw new Exception("Unhandled None value");
            }

            if (leftOperation.hasValue()) {
                if (getPrecedence(leftOperation.unwrap()) >= getPrecedence(binOp.unwrap())) {
                    return PReturnSome(leftExpr);
                }
            }

            input.consume(1);

            trace(binOp);

            var rightExprFlow = parser.parseNextPrimaryExpr();
            var rightExpr = switch rightExprFlow {
                case PReturnSome(expr): expr;
                case PParseError: return PParseError;
            }

            rightExprFlow = intoBinOpExpr(input, rightExpr, binOp, context, parser);
            rightExpr = switch rightExprFlow {
                case PReturnSome(expr): expr;
                case PParseError: return PParseError;
            }

            leftExpr = {
                kind: MExprKind.EBinop(leftExpr, rightExpr, binOp.unwrap()),
                pos: {
                    path: firstToken.pos.path,
                    min: firstToken.pos.min,
                    max: input.previous().pos.max,
                }
            };
        }

        return PReturnSome(leftExpr);
    }
}
