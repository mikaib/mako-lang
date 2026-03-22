package parsing;
import lexing.MToken;
import parsing.paths.MVarsPath.tryIntoEVars;
import parsing.paths.MIfPath.tryIntoEIf;
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
    ];

    var _tokens: ArrayView<MToken>;

    public function new(tokens: ArrayView<MToken>) {
        _tokens = tokens;
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (_tokens.length > 0) {
            for (path in pathsList) {
                var flowControl = path(_tokens);

                switch (flowControl) {
                    case PReturnSome(val): {
                        ast.push(val);
                        break;
                    }
                    case PNotParsed: continue;
                }
            }
            throw new Exception("Parsing failed, this part is unreachable in working code");
        }
        return ast;
    }
}