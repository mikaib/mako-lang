package lexing;

import core.MConst;

enum MTokenKind {
    MTokenOperator;
    TConst(const: MConst);
    TFunc;
    TParantOpen;
    TParantClose;
    TBracketOpen;
    TBracketClose;
    TColon;
    TSemiColon;
}

enum MTokenOperator {
    // Unary operators
    TInrement;
    TDecrement;
    TPlus;
    TMinus;
    TDivide;
    TMultiply;
    TAssign;
    TEqual;

    // Binary operators
    TBinOR;
    TBinXOR;
    TBinAND;
    TBinNOT;
}
