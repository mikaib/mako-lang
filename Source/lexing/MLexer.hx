package lexing;

import core.MOption;
import core.MChar;
import core.MOptionKind;
import core.MConst;
import lexing.MTokenKind.MTokenOperator;
import lexing.MTokenKind.MTokenKeyword;

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

    private function intoCString(stringToken:String): MOption<MConst> {
        if (stringToken.length < 2) {
            return None;
        }
        if (stringToken.charAt(0) != '"' || stringToken.charAt(stringToken.length - 1) != '"') {
            return None;
        }

        var sb = new StringBuf();
        var i = 1;
        while (i < stringToken.length - 1) {
            var c = stringToken.charAt(i);
            if (c == '\\') {
                if (i + 1 >= stringToken.length - 1) {
                    // " hello I'm \"
                    // Is probably not yet fully parsed and should not yet be converted into a CString
                    return None;
                }
                var next = stringToken.charAt(i + 1);
                switch (next) {
                    case '"': sb.add('"');
                    case '\\': sb.add('\\');
                    case 'n': sb.add('\n');
                    case 'r': sb.add('\r');
                    case 't': sb.add('\t');
                    default: sb.add(next);
                }
                i += 2;
            } else {
                sb.add(c);
                i++;
            }
        }

        return Some(CString(sb.toString()));
    }

    private function intoKeyword(stringToken: String): MOption<MTokenKeyword> {
        switch (stringToken) {
            case "const": MTokenKeyword.KConst;
            case "func": MTokenKeyword.KFunc;
            case "var": MTokenKeyword.KVar;
            case "if": MTokenKeyword.KIf;
            case "else": MTokenKeyword.KElse;
            case "while": MTokenKeyword.KWhile;
            case "do": MTokenKeyword.KDo;
            case "for": MTokenKeyword.KFor;
        }
        return None;
    }

    private function tokenFromString(input: String, stringToken: String): MOption<MToken> {
        var kind: MTokenKind = switch (stringToken) {
            case "<" if (peek(input).isVal("=")):
                readPos++;
                TTokenOperator(OLessThenEqualTo);

            case "<": TTokenOperator(OLessThenEqualTo);

            case ">" if (peek(input).isVal("=")):
                readPos++;
                TTokenOperator(OGreaterThenEqualTo);

            case ">": TTokenOperator(OGreatherThen);

            case "=" if (peek(input).isVal("=")):
                readPos++;
                TTokenOperator(OEqual);

            case "=": TTokenOperator(OAssign);

            case "!" if (peek(input).isVal("=")):
                readPos++;
                TTokenOperator(ONotEaqual);

            case "!": TTokenOperator(ONot);

            case "|" if (peek(input).isVal("|")):
                readPos++;
                TTokenOperator(OLogicalOr);

            case "|": TTokenOperator(OBitwiseOr);

            case "&" if (peek(input).isVal("&")):
                readPos++;
                TTokenOperator(OLogicalAnd);

            case "&": TTokenOperator(OBitwiseAnd);

            case "-" if (peek(input).isVal(">")):
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

        if (kind == TNone && stringToken.charCodeAt(0) == '"'.code) {
            var cstring = intoCString(stringToken);
            if (cstring.hasValue()) {
                kind = TConst(cstring.unwrap());
            }
            else {
                return None;
            }
        }

        var next = peek(input);
        if(kind == TNone && next.hasValue() && isDelimeter(next.unwrap())) {
            var keyword = intoKeyword(stringToken);
            if (keyword.hasValue()) {
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
            if (char.hasValue()) {
                var c = char.unwrap();

                // skip leading spaces
                if (currentStringBuf.length == 0 && (c == ' '.code || c == '\t'.code || c == '\n'.code || c == '\r'.code)) {
                    continue;
                }

                currentStringBuf.addChar(c);
                var token: MOption<MToken> = tokenFromString(_input, currentStringBuf.toString());
                if (token.hasValue()) {
                    currentTokens.push(token.unwrap());
                    currentStringBuf = new StringBuf();
                }
            }
        } while (char.hasValue());
        return currentTokens;
    }

}
