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

    // operator precedence parser
    public static function intoOperationAST(input: ArrayView<MToken>, leftExpr: MExpr, leftOperation: MOption<MBinop>, context: Context, parser: MParser): ParserFlowControl {
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
                throw new Exception("Unhandles None value");
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

            rightExprFlow = intoOperationAST(input, rightExpr, binOp, context, parser);
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
