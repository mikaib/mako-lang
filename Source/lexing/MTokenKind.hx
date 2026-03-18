package lexing;

import core.MConst;

enum MTokenKind {
    TNone;
    TTokenOperator(op: MTokenOperator);
    TConst(const: MConst);
    TKeyword(keyword: MTokenKeyword);
    TFuncAssign;
    TParantOpen;
    TParantClose;
    TBraceOpen;
    TBraceClose;
    TBracketOpen;
    TBracketClose;
    TQuestion;
    TColon;
    TSemiColon;
    TComma;
}

enum MTokenKeyword {
    KFunc;
    KClass;
    KPublic;
    KPrivate;
    KReturn;
    KConst;
    KVar;
    KIf;
    KElse;
    KWhile;
    KDo;
    KFor;
}

enum MTokenOperator {
    OIncrement;
    ODecrement;
    OPlus;
    OMinus;
    ODivide;
    OMultiply;
    OAssign;
    OEqual;
    ONotEaqual;
    OGreatherThen;
    OGreaterThenEqualTo;
    OLessThen;
    OLessThenEqualTo;
    ORotateLeft;
    ORotateRight;
    OBitwiseOr;
    OLogicalOr;
    OBitwiseAnd;
    OLogicalAnd;
    OBitwiseXor;
    ONot;
    OXor;
    OAddAssign;
    OSubtractAssign;
    OMultiplyAssign;
    ODivideAssign;
    OOrAssign;
    OAndAssign;
    OXorAssign;
}

class MTokenUtil {

    public static function tokenKindToString(kind:MTokenKind):String {
        return switch (kind) {
            case TNone: "None";

            case TTokenOperator(op):
                "Operator(" + operatorToString(op) + ")";

            case TConst(c):
                "Const(" + Std.string(c) + ")";

            case TKeyword(k):
                "Keyword(" + keywordToString(k) + ")";

            case TParantOpen: "(";
            case TParantClose: ")";
            case TBraceOpen: "{";
            case TBraceClose: "}";
            case TBracketOpen: "[";
            case TBracketClose: "]";

            case TFuncAssign: "->";
            case TQuestion: "?";
            case TColon: ":";
            case TSemiColon: ";";
            case TComma: ",";

            default : "UnhandledToken";
        }
    }

    static function keywordToString(k:MTokenKeyword):String {
        return switch (k) {
            case KFunc: "func";
            case KClass: "class";
            case KPublic: "public";
            case KPrivate: "private";
            case KReturn: "return";
            case KConst: "const";
            case KVar: "var";
            case KIf: "if";
            case KElse: "else";
            case KWhile: "while";
            case KDo: "do";
            case KFor: "for";
            default : "UnhandledKeyword";
        }
    }

    static function operatorToString(op:MTokenOperator):String {
        return switch (op) {
            case OIncrement: "++";
            case ODecrement: "--";
            case OPlus: "+";
            case OMinus: "-";
            case ODivide: "/";
            case OMultiply: "*";
            case OAssign: "=";
            case OEqual: "==";
            case ONotEaqual: "!=";
            case OGreatherThen: ">";
            case OGreaterThenEqualTo: ">=";
            case OLessThen: "<";
            case OLessThenEqualTo: "<=";
            case ORotateLeft: "<<";
            case ORotateRight: ">>";
            case OBitwiseOr: "|";
            case OLogicalOr: "||";
            case OBitwiseAnd: "&";
            case OLogicalAnd: "&&";
            case OBitwiseXor: "^";
            case ONot: "!";
            case OXor: "^";
            case OAddAssign: "+=";
            case OSubtractAssign: "-=";
            case OMultiplyAssign: "*=";
            case ODivideAssign: "/=";
            case OOrAssign: "|=";
            case OAndAssign: "&=";
            case OXorAssign: "^=";
            default : "UnhandledOperator";
        }
    }
}
