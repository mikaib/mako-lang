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

    private function tokenFromString(input: String, stringToken: String): Option<MToken> {
        var kind: MTokenKind = switch (stringToken) {
            case "<" if (peek(input) == "="):
                readPos++;
                TTokenOperator(OLessThenEqualTo);

            case "<": TTokenOperator(OLessThenEqualTo);

            case ">" if (peek(input) == "="):
                readPos++;
                TTokenOperator(OGreaterThenEqualTo);

            case ">": TTokenOperator(OGreatherThen);

            case "=" if (peek(input) == "="):
                readPos++;
                TTokenOperator(OEqual);

            case "=": TTokenOperator(OAssign);

            case "!" if (peek(input) == "="):
                readPos++;
                TTokenOperator(ONotEaqual);

            case "!": TTokenOperator(ONot);

            case "|" if (peek(input) == "|"):
                readPos++;
                TTokenOperator(OLogicalOr);

            case "|": TTokenOperator(OBitwiseOr);

            case "&" if (peek(input) == "&"):
                readPos++;
                TTokenOperator(OLogicalAnd);

            case "&": TTokenOperator(OBitwiseAnd);

            case "(": TParantOpen;
            case ")": TParantClose;
            case "{": TBracketOpen;
            case "}": TBracketClose;
            case ":": TColon;
            case "?": TQuestion;
            case ";": TSemiColon;
        }



        if (kind == TNone) {
            return None;
        }

        return Some({ kind: kind, pos: null });
    }

    public function lexTokens(input: String): Array<MToken> {
        // We might want to consider to implement an array like string buffer for improved performance
        var currentStringBuf: StringBuf;
        var currentTokens: Array<MToken> = [];

        do {
            var char: Option<MChar> = readChar(input);
            if (char != None) {
                currentStringBuf.addChar(char.sure());
                var token: Option<MToken> = tokenFromString(input, currentStringBuf.toString());
                if (token != None) {
                    currentTokens.push(token.sure());
                    currentStringBuf.new();
                }
            }
        } while (char != None);
        return currentTokens;
    }

}
