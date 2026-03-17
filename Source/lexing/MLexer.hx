package lexing;

import haxe.ds.Option;
import core.MChar;
import lexing.MTokenKind.MTokenOperator;

class MLexer {

    private var readPos: Int;

    private function peek(input: String): Option<MChar> {
        if (input.length > readPos + 1) {
            return None;
        }
        
        return Some(input.charCodeAt(readPos + 1));
    }

    private function readChar(input: String): Option<MChar> {
        if (input.length > readPos + 1) {
            return None;
        }

        return Some(input.charCodeAt(++readPos));
    }

    public static function tokenFromString(input: String, stringToken: String): Option<MToken> {
        switch (x) {
            case "<":
                if (peek(input) == "=") {
                    return Some({ kind: TTokenOperator(OLessThenEqualTo), pos: null });
                }
                return Some({ kind: TTokenOperator(OLessThenEqualTo), pos: null });
            case ">":
                if (peek(input) == "=") {
                    return Some({ kind: TTokenOperator(OGreaterThenEqualTo), pos: null });
                }
                return Some({ kind: TTokenOperator(OGreatherThen), pos: null });
            case "=":
                if (peek(input) == "=") {
                    return Some({ kind: TTokenOperator(OGreaterThenEqualTo), pos: null });
                }
                return Some({ kind: TTokenOperator(OGreatherThen), pos: null });
        }
        return null;
    }

    public function lexTokens(input: String): Array<MToken> {
        // We might want to consider to implement an array like string buffer for improved performance
        var currentStringBuf: StringBuf;
        var currentTokens: Array<MToken> = [];

        do {
            var char: Option<MChar> = readChar(input);
            if (char != None) {
                currentStringBuf.addChar(char.sure());
                var token: MToken = MTokenTools.tokenFromString(currentStringBuf.toString());
                if (token != None) {
                    currentTokens.push(token);
                    currentStringBuf.new();
                }
            }
        } while (char != None);
        return currentTokens;
    }

}
