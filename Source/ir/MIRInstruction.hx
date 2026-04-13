package ir;

@:structInit
class MIRInstruction {
    public var kind: MIRInstructionKind;
    public var data: Array<MIROperand> = [];
    public var result: MIRResult = {};
}
