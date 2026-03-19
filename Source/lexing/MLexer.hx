package lexing;

import core.MOption;
import core.MChar;
import core.MOptionKind;
import core.MConst;
import lexing.MTokenKind.MTokenOperator;
import lexing.MTokenKind.MTokenKeyword;
import core.MPositionRange;

typedef MControlFunc = (String, MOption<MChar>) -> LexerFlowControl;

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

    private function intoCIdent(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        if (next.hasValue() && next.unwrap().isAlphaNumeric()) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        return {flowControl: LReturnSome(TConst(MConst.CIdent(stringToken))), advanceBy: 0};
    }

    private function intoCBool(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        if (next.hasValue() && next.unwrap().isAlphaNumeric()) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        switch(stringToken) {
            case "true": return {flowControl: LReturnSome(TConst(CBool(true))), advanceBy: 0};
            case "false": return {flowControl: LReturnSome(TConst(CBool(false))), advanceBy: 0};
            default: return {flowControl: LAdvance, advanceBy: 0};
        }
    }

    private function intoCFloat(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        if (next.hasValue() && !isDelimeter(next.unwrap())) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        var found_dot = false;
        for (i in 0...stringToken.length) {
            var c = stringToken.charCodeAt(i);
            if (c == '.'.code) {
                if (found_dot) {
                    return {flowControl: LAdvance, advanceBy: 0};
                }
                found_dot = true;
            }
            else if (c <= '0'.code || c >= '9'.code) {
                return {flowControl: LAdvance, advanceBy: 0};
            }
        }

        if (!found_dot) {
            return {flowControl: LAdvance, advanceBy: 0};
        }

        return {flowControl: LReturnSome(TConst(CFloat(stringToken))), advanceBy: 0};
    }

    private function intoCInt(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        if (next.hasValue() && (next.isValue('.'.code) || !isDelimeter(next.unwrap()))) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        for (i in 0...stringToken.length) {
            var c = stringToken.charCodeAt(i);
            if (c < '0'.code || c > '9'.code) {
                return {flowControl: LAdvance, advanceBy: 0};
            }
        }

        return {flowControl: LReturnSome(TConst(CInt(stringToken))), advanceBy: 0};
    }

    private function intoCString(stringToken: String, _: MOption<MChar>): LexerFlowControl {
        if (stringToken.charCodeAt(0) != '"'.code) {
            return {flowControl: LAdvance, advanceBy: 0};
        }
        if (stringToken.length < 2) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        if (stringToken.charAt(stringToken.length - 1) != '"') {
            return {flowControl: LReturnNone, advanceBy: 0};
        }

        var sb = new StringBuf();
        var i = 1;
        while (i < stringToken.length - 1) {
            var c = stringToken.charAt(i);
            if (c == '\\') {
                if (i + 1 >= stringToken.length - 1) {
                    // "Hello, I'm \"
                    // Is probably not yet fully parsed and should not yet be converted into a CString
                    return {flowControl: LReturnNone, advanceBy: 0};
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

        return {flowControl: LReturnSome(TConst(CString(sb.toString()))), advanceBy: 0};
    }

    private function intoKeyword(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        if (next.hasValue() && next.unwrap().isAlphaNumeric()) {
            return {flowControl: LReturnNone, advanceBy: 0};
        }
        switch (stringToken) {
            case "func": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KFunc)), advanceBy: 0};
            case "class": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KClass)), advanceBy: 0};
            case "public": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KPublic)), advanceBy: 0};
            case "private": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KPrivate)), advanceBy: 0};
            case "return": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KReturn)), advanceBy: 0};
            case "const": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KConst)), advanceBy: 0};
            case "var": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KVar)), advanceBy: 0};
            case "if": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KIf)), advanceBy: 0};
            case "else": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KElse)), advanceBy: 0};
            case "while": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KWhile)), advanceBy: 0};
            case "do": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KDo)), advanceBy: 0};
            case "for": return {flowControl: LReturnSome(TKeyword(MTokenKeyword.KFor)), advanceBy: 0};
        }
        return {flowControl: LAdvance, advanceBy: 0};
    }

    private function intoOperator(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        switch (stringToken) {
            case "<" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OLessThenEqualTo)), advanceBy: 1};
            case "<" if (next.isValue("<")):
                return {flowControl: LReturnSome(TTokenOperator(OShiftLeft)), advanceBy: 1};
            case "<": return {flowControl: LReturnSome(TTokenOperator(OLessThen)), advanceBy: 0};

            case ">" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OGreaterThenEqualTo)), advanceBy: 1};
            case ">" if (next.isValue(">")):
                return {flowControl: LReturnSome(TTokenOperator(OShiftRight)), advanceBy: 1};
            case ">": return {flowControl: LReturnSome(TTokenOperator(OGreatherThen)), advanceBy: 0};

            case "=" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OEqual)), advanceBy: 1};
            case "=": return {flowControl: LReturnSome(TTokenOperator(OAssign)), advanceBy: 0};

            case "!" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(ONotEaqual)), advanceBy: 1};
            case "!": return {flowControl: LReturnSome(TTokenOperator(ONot)), advanceBy: 0};

            case "|" if (next.isValue("|")):
                return {flowControl: LReturnSome(TTokenOperator(OLogicalOr)), advanceBy: 1};
            case "|" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OOrAssign)), advanceBy: 1};
            case "|": return {flowControl: LReturnSome(TTokenOperator(OBitwiseOr)), advanceBy: 0};

            case "^" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OXorAssign)), advanceBy: 1};
            case "^": return {flowControl: LReturnSome(TTokenOperator(OBitwiseXor)), advanceBy: 0};

            case "&" if (next.isValue("&")):
                return {flowControl: LReturnSome(TTokenOperator(OLogicalAnd)), advanceBy: 1};
            case "&" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OAndAssign)), advanceBy: 1};
            case "&": return {flowControl: LReturnSome(TTokenOperator(OBitwiseAnd)), advanceBy: 0};

            case "*" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OMultiplyAssign)), advanceBy: 1};
            case "*": return {flowControl: LReturnSome(TTokenOperator(OMultiply)), advanceBy: 0};

            case "/" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(ODivideAssign)), advanceBy: 1};
            case "/": return {flowControl: LReturnSome(TTokenOperator(ODivide)), advanceBy: 0};

            case "+" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OAddAssign)), advanceBy: 1};
            case "+": return {flowControl: LReturnSome(TTokenOperator(OPlus)), advanceBy: 0};

            case "-" if (next.isValue("=")):
                return {flowControl: LReturnSome(TTokenOperator(OSubtractAssign)), advanceBy: 1};
            case "-": return {flowControl: LReturnSome(TTokenOperator(OMinus)), advanceBy: 0};

            default:
                return {flowControl: LAdvance, advanceBy: 0};
        }
    }

    private function intoToken(stringToken: String, next: MOption<MChar>): LexerFlowControl {
        switch (stringToken) {
            case "-" if (next.isValue(">")): return {flowControl: LReturnSome(TFuncAssign), advanceBy: 1};
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

    private function tokenKindFromString(input: String, stringToken: String): MOption<MTokenKind> {
        var next = peek(input);

        var controlList: Array<MControlFunc> = [
            intoToken,
            intoOperator,
            intoCString,
            intoCInt,
            intoCFloat,
            intoCBool,
            intoKeyword,
            intoCIdent
        ];

        for (cl in controlList) {
            var flowControl = cl(stringToken, next);
            advanceChars(input, flowControl.advanceBy);

            switch (flowControl.flowControl) {
                case LReturnSome(val): return Some(val);
                case LReturnNone: return None;
                case LAdvance: continue;
            }
        }

        return None;
    }

    private function tokenFromString(input: String, stringToken: String): MOption<MToken> {
        var tokenKind = tokenKindFromString(input, stringToken);
        if (!tokenKind.hasValue()) {
            return None;
        }
        var position: MPositionRange = {
            min: {
                line: lastTokenLineNumber,
                column: lastTokenCharIndex
            },
            max: {
                line: currentLineNumber,
                column: currentCharIndex
            },
            path: _filePath
        }
        updateLastTokenPosition(currentLineNumber, currentCharIndex);

        return Some({ kind: tokenKind.unwrap(), pos: position});
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
