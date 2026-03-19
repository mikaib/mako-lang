package core;
import typing.MType;

@:structInit
class MFuncArg {
    public var name: String;
    public var type: MType = MType.mono();
}
