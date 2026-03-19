package parsing;
import lexing.MToken;
import parsing.paths.MVarsPath.tryIntoEVars;

typedef ParserPathsList = (Array<MToken>, Int) -> ParserFlowControl;

typedef ParserFlowControl = {
    flowControl: ParserFlowControlEnum,
    consumedTokens: Int,
}

enum ParserFlowControlEnum {
    LReturnSome(expr:MExpr);
    LAdvance;
}

class MParser {

    static var pathsList: Array<ParserPathsList> = [
        tryIntoEVars,
    ];

    var _tokens: Array<MToken>;
    var read_index = 0;

    public function new(tokens: Array<MToken>) {
        _tokens = tokens;
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (read_index < _tokens.length) {
            for (path in pathsList) {
                var flowControl = path(_tokens, read_index);
                read_index += flowControl.consumedTokens;

                switch (flowControl.flowControl) {
                    case LReturnSome(val): {
                        ast.push(val);
                        break;
                    }
                    case LAdvance: continue;
                }
            }
        }
        return ast;
    }
}