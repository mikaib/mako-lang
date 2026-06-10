package core;

enum MBinop {
    Add;
    Sub;
    Mul;
    Eq;
    NotEq;
    Div;
    Mod;
    Or;
    And;
    BitOr;
    BitAnd;
    BitXor;
    LessThan;
    GreaterThan;
    EqualGreaterThan;
    EqualLessThan;
    Assign;
    AssignOp(op: MBinop);
}
