package parsing;
import core.MOption;
import core.MOptionKind;
import lexing.MToken;
import parsing.paths.MVarsPath;
import parsing.paths.MIfPath;
import parsing.paths.MParantPath;
import parsing.paths.MReturnPath;
import parsing.paths.MConstPath;
import parsing.paths.MOperatorPath;
import parsing.paths.MFunctionPath;
import parsing.paths.MBlockPath;
import core.MArrayView.ArrayView;
import lexing.MTokenKind.MTokenKeyword;
import haxe.exceptions.NotImplementedException;
import lexing.MTokenKind;

typedef ParserPathsList = (ArrayView<MToken>) -> ParserFlowControl;

enum ParserFlowControl {
    PReturnSome(expr:MExpr);
    PReturnEaten;
    PNotParsed;
}

class MParser {

    static var pathsList: Array<ParserPathsList> = [
        MFunctionPath.tryIntoEFunction,
        MVarsPath.tryIntoEVars,
        MOperatorPath.tryIntoEOperation,
        MConstPath.tryIntoEConst,
    ];

    var tokens: ArrayView<MToken>;

    public function new(_tokens: ArrayView<MToken>) {
        tokens = _tokens;
    }

    public function intoMExpr(): MOption<MExpr> {
        if (tokens.length < 1) {
            return None;
        }

        var expressions = parseTree();
        if (expressions.length > 1) {
            throw new NotImplementedException("expressions length was more then 1");
        }

        return Some(expressions[0]);
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (tokens.length > 0) {
            var flowControl = switch (tokens[0].kind) {
                case TKeyword(KIf):
                    MIfPath.intoEIf(tokens);
                case TParantOpen:
                    MParantPath.intoEParent(tokens);
                case TKeyword(KReturn):
                    MReturnPath.intoEReturn(tokens);
                case TBraceOpen:
                    MBlockPath.tryIntoEBlock(tokens);
                default:
                    PNotParsed;
            }

            switch (flowControl) {
                case PReturnSome(val): {
                    ast.push(val);
                    return ast;
                }
                default:
            }

            var parsed = false;
            for (path in pathsList) {
                var flowControl = path(tokens);

                switch (flowControl) {
                    case PReturnSome(val): {
                        ast.push(val);
                        parsed = true;
                        break;
                    }
                    case PReturnEaten: {
                            parsed = true;
                            break;
                        }
                    case PNotParsed: continue;
                }
            }
            if (!parsed) {
                trace("Not all tokens could be parsed");
                return ast;
            }
        }
        return ast;
    }
}