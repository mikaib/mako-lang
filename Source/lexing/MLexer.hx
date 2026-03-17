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

    private function intoCBool(stringToken: String): MOption<MConst> {
        switch(stringToken) {
            case "true": return Some(MConst.CBool(true));
            case "false": return Some(MConst.CBool(false));
            default: return None;
        }
    }

    private function intoCFloat(stringToken: String): MOption<MConst> {
        var found_dot = false;
        for (i in 0...stringToken.length) {
            var c = stringToken.charCodeAt(i);
            if (c == '.'.code) {
                if (found_dot) {
                    return None;
                }
                found_dot = true;
            }
            else if (c <= '0'.code || c >= '9'.code) {
                return None;
            }
        }

        if (!found_dot) {
            return None;
        }

        return Some(MConst.CFloat(stringToken));
    }

    private function intoCInt(stringToken: String): MOption<MConst> {
        for (i in 0...stringToken.length) {
            var c = stringToken.charCodeAt(i);
            if (c <= '0'.code || c >= '9'.code) {
                return None;
            }
        }

        return Some(MConst.CInt(stringToken));
    }

    private function intoCString(stringToken: String): MOption<MConst> {
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
            case "func": return Some(MTokenKeyword.KFunc);
            case "return": return Some(MTokenKeyword.KReturn);
            case "const": return Some(MTokenKeyword.KConst);
            case "var": return Some(MTokenKeyword.KVar);
            case "if": return Some(MTokenKeyword.KIf);
            case "else": return Some(MTokenKeyword.KElse);
            case "while": return Some(MTokenKeyword.KWhile);
            case "do": return Some(MTokenKeyword.KDo);
            case "for": return Some(MTokenKeyword.KFor);
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
            case "*": TTokenOperator(OMultiply);
            case "/": TTokenOperator(ODivide);
            case "+": TTokenOperator(OPlus);
            case "-": TTokenOperator(OMinus);
            default : TNone;
        }

        if (kind == TNone && stringToken.charCodeAt(0) == '"'.code) {
            var cString = intoCString(stringToken);
            if (cString.hasValue()) {
                kind = TConst(cString.unwrap());
            }
            else {
                return None;
            }
        }

        var next = peek(input);
        if (kind == TNone && next.hasValue() && !next.isVal('.') && isDelimeter(next.unwrap())) {
            var cInt = intoCInt(stringToken);
            if (cInt.hasValue()) {
                kind = TConst(cInt.unwrap());
            }
        }

        if (kind == TNone && next.hasValue() && isDelimeter(next.unwrap())) {
            var cFloat= intoCFloat(stringToken);
            if (cFloat.hasValue()) {
                kind = TConst(cFloat.unwrap());
            }
            else if (next.isVal('.')) {
                return None;
            }
        }

        if (kind == TNone && next.hasValue() && isDelimeter(next.unwrap())) {
            var cBool= intoCBool(stringToken);
            if (cBool.hasValue()) {
                kind = TConst(cBool.unwrap());
            }
        }

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
