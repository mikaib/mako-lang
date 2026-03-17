package lexing;

import core.MOption;
import core.MChar;
import lexing.MTokenKind.MTokenOperator;
import core.MOptionKind;
import lexing.MTokenKind.MTokenKeyword;
import core.MConst;

class MLexer {

    private var readPos: Int = 0;
    private var _input: String;

    public function new(input: String) {
        _input = input;
    }

    private function peek(input: String): MOption<MChar> {
        if (readPos > input.length - 2) {
            return None;
        }

        return Some(input.charCodeAt(readPos + 1));
    }

    private function readChar(input: String): MOption<MChar> {
        if (readPos  > input.length - 2) {
            return None;
        }

        return Some(input.charCodeAt(++readPos));
    }

    private function isDelimeter(char: MChar): Bool {
        if (char.isAlphaNumeric() || char == '_'.code) {
            return false;
        }
        return true;
    }

    private function intoKeyword(stringToken: String): MOption<MTokenKeyword> {
        switch (stringToken) {
            case "const": MTokenKeyword.KConst;
            case "func": MTokenKeyword.KFunc;
            case "var": MTokenKeyword.KVar;
        }
        return None;
    }

    private function tokenFromString(input: String, stringToken: String): MOption<MToken> {
        var kind: MTokenKind = switch (stringToken) {
            case "<" if (peek(input) != None && peek(input).unwrap() == "="):
                readPos++;
                TTokenOperator(OLessThenEqualTo);

            case "<": TTokenOperator(OLessThenEqualTo);

            case ">" if (peek(input) != None && peek(input).unwrap() == "="):
                readPos++;
                TTokenOperator(OGreaterThenEqualTo);

            case ">": TTokenOperator(OGreatherThen);

            case "=" if (peek(input) != None && peek(input).unwrap() == "="):
                readPos++;
                TTokenOperator(OEqual);

            case "=": TTokenOperator(OAssign);

            case "!" if (peek(input) != None && peek(input).unwrap() == "="):
                readPos++;
                TTokenOperator(ONotEaqual);

            case "!": TTokenOperator(ONot);

            case "|" if (peek(input) != None && peek(input).unwrap() == "|"):
                readPos++;
                TTokenOperator(OLogicalOr);

            case "|": TTokenOperator(OBitwiseOr);

            case "&" if (peek(input) != None && peek(input).unwrap() == "&"):
                readPos++;
                TTokenOperator(OLogicalAnd);

            case "&": TTokenOperator(OBitwiseAnd);

            case "-" if (peek(input) != None && peek(input).unwrap() == ">"):
                readPos++;
                TFuncAssign;

            case "(": TParantOpen;
            case ")": TParantClose;
            case "{": TBraceOpen;
            case "}": TBraceClose;
            case "[": TBracketOpen;
            case "]": TBracketClose;
            case ":": TColon;
            case "?": TQuestion;
            case ";": TSemiColon;
            case ",": TComma;
            default : TNone;
        }

        var next = peek(input);
        if(kind == TNone && next != None && isDelimeter(next.unwrap())) {
            var keyword = intoKeyword(stringToken);
            if (keyword != None) {
                kind = TKeyword(keyword.unwrap());
            }
            else {
                kind = TConst(MConst.CIdent(stringToken));
            }
        }


        if (kind == TNone) {
            return None;
        }

        return Some({ kind: kind, pos: null });
    }

    public function lexTokens(): Array<MToken> {
        // We might want to consider to implement an array like string buffer for improved performance
        var currentStringBuf: StringBuf = new StringBuf();
        var currentTokens: Array<MToken> = [];

        var char: MOption<MChar>;

        do {
            char = readChar(_input);
            if (char != None) {
                var c = char.unwrap();

                // skip leading spaces
                if (currentStringBuf.length == 0 && (c == ' '.code || c == '\t'.code || c == '\n'.code || c == '\r'.code)) {
                    continue;
                }

                currentStringBuf.addChar(c);
                var token: MOption<MToken> = tokenFromString(_input, currentStringBuf.toString());
                if (token != None) {
                    currentTokens.push(token.unwrap());
                    currentStringBuf = new StringBuf();
                }
            }
        } while (char != None);
        return currentTokens;
    }

}
