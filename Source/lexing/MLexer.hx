package lexing;

import core.MOption;
import core.MChar;
import core.MOptionKind;
import core.MConst;
import lexing.MTokenKind.MTokenOperator;
import lexing.MTokenKind.MTokenKeyword;
import core.MPositionRange;

typedef LexerFlowControl = {
    flowControl: LexerFlowControlEnum,
    advanceBy: Int,
}

enum LexerFlowControlEnum {
    LReturnSome(kind:MTokenKind);
    LReturnNone;
    LAdvance;
}

class MLexer {

    private var readPos: Int = 0;
    private var _input: String;

    private var _filePath: String;
    private var currentLineNumber: Int = 1;
    private var currentCharIndex: Int = 1;

    private var lastTokenLineNumber: Int = 1;
    private var lastTokenCharIndex: Int = 1;

    public function new(input: String, filePath: String) {
        _input = input;
        _filePath = filePath;
    }

    private function peek(input: String): MOption<MChar> {
        if (readPos > input.length - 1) {
            return None;
        }

        return Some(input.charCodeAt(readPos));
    }

    private function updateCurrentPosition(lineNumber: Int, charIndex: Int) {
        currentLineNumber = lineNumber;
        currentCharIndex = charIndex;
    }

    private function updateLastTokenPosition(lineNumber: Int, charIndex: Int) {
        lastTokenLineNumber = lineNumber;
        lastTokenCharIndex = charIndex;
    }

    private function readChar(input: String): MOption<MChar> {
        if (readPos  > input.length - 1) {
            return None;
        }

        var char = input.charCodeAt(readPos++);
        if (char == '\n'.code) {
            updateCurrentPosition(currentLineNumber + 1, 1);
        } else {
            updateCurrentPosition(currentLineNumber, currentCharIndex + 1);
        }

        return Some(char);
    }

    private function advanceChars(input: String, count: Int) {
        for (i in 0...count) {
            readChar(input);
        }
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
                    // "Hello, I'm \"
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
            case "class": return Some(MTokenKeyword.KClass);
            case "public": return Some(MTokenKeyword.KPublic);
            case "private": return Some(MTokenKeyword.KPrivate);
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

    private function intoOperator(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        switch (stringToken) {
            case "<" if (next.isVal("=")):
                return {flowControl: LReturnSome(TTokenOperator(OLessThenEqualTo)), advanceBy: 1};
            case "<": return {flowControl: LReturnSome(TTokenOperator(OLessThen)), advanceBy: 0};

            case ">" if (next.isVal("=")):
                return {flowControl: LReturnSome(TTokenOperator(OGreaterThenEqualTo)), advanceBy: 1};
            case ">": return {flowControl: LReturnSome(TTokenOperator(OGreatherThen)), advanceBy: 0};

            case "=" if (next.isVal("=")):
                return {flowControl: LReturnSome(TTokenOperator(OEqual)), advanceBy: 1};
            case "=": return {flowControl: LReturnSome(TTokenOperator(OAssign)), advanceBy: 0};

            case "!" if (next.isVal("=")):
                return {flowControl: LReturnSome(TTokenOperator(ONotEaqual)), advanceBy: 1};
            case "!": return {flowControl: LReturnSome(TTokenOperator(ONot)), advanceBy: 0};

            case "|" if (next.isVal("|")):
                return {flowControl: LReturnSome(TTokenOperator(OLogicalOr)), advanceBy: 1};
            case "|": return {flowControl: LReturnSome(TTokenOperator(OBitwiseOr)), advanceBy: 0};

            case "&" if (next.isVal("&")):
                return {flowControl: LReturnSome(TTokenOperator(OLogicalAnd)), advanceBy: 1};
            case "&": return {flowControl: LReturnSome(TTokenOperator(OBitwiseAnd)), advanceBy: 0};

            case "*": return {flowControl: LReturnSome(TTokenOperator(OMultiply)), advanceBy: 0};
            case "/": return {flowControl: LReturnSome(TTokenOperator(ODivide)), advanceBy: 0};
            case "+": return {flowControl: LReturnSome(TTokenOperator(OPlus)), advanceBy: 0};
            case "-": return {flowControl: LReturnSome(TTokenOperator(OMinus)), advanceBy: 0};

            default:
                return {flowControl: LAdvance, advanceBy: 0};
        }
    }

    private function intoToken(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        switch (stringToken) {
            case "-" if (next.isVal(">")): return {flowControl: LReturnSome(TFuncAssign), advanceBy: 1};
            case "(": return {flowControl: LReturnSome(TParantOpen), advanceBy: 0};
            case ")": return {flowControl: LReturnSome(TParantClose), advanceBy: 0};
            case "{": return {flowControl: LReturnSome(TBraceOpen), advanceBy: 0};
            case "}": return {flowControl: LReturnSome(TBraceClose), advanceBy: 0};
            case "[": return {flowControl: LReturnSome(TBracketOpen), advanceBy: 0};
            case "]": return {flowControl: LReturnSome(TBracketClose), advanceBy: 0};
            case ":": return {flowControl: LReturnSome(TColon), advanceBy: 0};
            case "?": return {flowControl: LReturnSome(TQuestion), advanceBy: 0};
            case ";": return {flowControl: LReturnSome(TSemiColon), advanceBy: 0};
            case ",": return {flowControl: LReturnSome(TComma), advanceBy: 0};
            default:
                return {flowControl: LAdvance, advanceBy: 0};
        }
    }

    private function tokenFromString(input: String, stringToken: String): MOption<MToken> {
        var flowControl;
        var next = peek(input);

        flowControl = intoOperator(input, next);
        advanceChars(input, flowControl.advanceBy);
        switch (flowControl.flowControl) {
            case LReturnSome(val): return Some(val);
            case LReturnNone: return None;
            case LAdvance:
        }

        flowControl = intoToken(input, next);
        advanceChars(input, flowControl.advanceBy);
        switch (flowControl.flowControl) {
            case LReturnSome(val): return Some(val);
            case LReturnNone: return None;
            case LAdvance:
        }

        var kind: MTokenKind = TNone;

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

        var position: MPositionRange = { min: {path: _filePath, line: lastTokenLineNumber, column: lastTokenCharIndex}, max: {path: _filePath, line: currentLineNumber, column: currentCharIndex}}
        updateLastTokenPosition(currentLineNumber, currentCharIndex);

        return Some({ kind: kind, pos: position});
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
                    updateLastTokenPosition(currentLineNumber, currentCharIndex);
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
