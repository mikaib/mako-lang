package ir;

import typing.MType;
import core.MConst;

enum MIROperand {
    None;
    Register(x: MIRRegister);
    Function(x: String);
    Type(x: MType);
    Int(x: Int);
    Float(x: Float);
    String(x: String);
    Bool(x: Bool);
}
