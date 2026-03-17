package lexing;

import core.MConst;

enum MTokenKind {
    TTokenOperator(op: MTokenOperator);
    TConst(const: MConst);
    TFunc;
    TParantOpen;
    TParantClose;
    TBracketOpen;
    TBracketClose;
    TQuestion;
    TColon;
    TSemiColon;
}

enum MTokenOperator {
    // Unary operators
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
    OPipe;
    OAnd;
    OXor;
    ONot;
}
