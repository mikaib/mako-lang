package core;

enum MBinop {
    Add;
    Sub;
    Mul;
    Eq;
    NotEq;
    GreaterThen;
    GreaterThenEqualTo;
    LessThen;
    LessThenEqualTo;
    Div;
    Mod;
    Or;
    And;
    BitOr;
    BitAnd;
    BitXor;
    Equal;
    NotEqual;
    LessThan;
    GreaterThan;
    EqualGreaterThan;
    EqualLessThan;
    Assign;
    AssignOp(op: MBinop);
}
