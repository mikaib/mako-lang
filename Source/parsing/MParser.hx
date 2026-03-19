package parsing;
import lexing.MToken;

class MParser {

    var _tokens: Array<MToken>;

    function new(tokens: Array<MToken>) {
        _tokens = tokens;
    }

    function parseTree(): List<MExpr> {

    }
}