package ir;

import typing.MType;

@:structInit
class MIRFunction {
    public var name: String;
    public var parameters: Array<MIRParameter> = [];
    public var returnType: MType = MType.voidType();
    public var instructions: Array<MIRInstruction> = [];
}
