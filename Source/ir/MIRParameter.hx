package ir;

import typing.MType;

@:structInit
class MIRParameter {
    public var name: String;
    public var register: MIRRegister;
    public var type: MType;
}
