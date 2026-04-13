package ir;

import typing.MType;

@:structInit
class MIRResult {
    public var register: MIRRegister = -1;
    public var type: MType = MType.voidType();
}
