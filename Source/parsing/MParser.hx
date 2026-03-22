package parsing;
import lexing.MToken;
import parsing.paths.MVarsPath.tryIntoEVars;
import parsing.paths.MIfPath.tryIntoEIf;
import parsing.paths.MReturnPath.tryIntoEReturn;
import parsing.paths.MConstPath.tryIntoEConst;
import core.MArrayView.ArrayView;
import haxe.Exception;

typedef ParserPathsList = (ArrayView<MToken>) -> ParserFlowControl;

enum ParserFlowControl {
    PReturnSome(expr:MExpr);
    PNotParsed;
}

class MParser {

    static var pathsList: Array<ParserPathsList> = [
        tryIntoEVars,
        tryIntoEIf,
        tryIntoEReturn,
        tryIntoEConst,
    ];

    var _tokens: ArrayView<MToken>;

    public function new(tokens: ArrayView<MToken>) {
        _tokens = tokens;
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (_tokens.length > 0) {
            var parsed = false;
            for (path in pathsList) {
                var flowControl = path(_tokens);

                switch (flowControl) {
                    case PReturnSome(val): {
                        ast.push(val);
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