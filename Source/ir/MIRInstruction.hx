package ir;

@:structInit
class MIRInstruction {

    public var kind: MIRInstructionKind;
    public var data: Array<MIROperand> = [];
    public var result: MIRResult = {};

    public function toString(): String {
        return 'MIRInstruction(kind=$kind, data=$data, result=$result)';
    }

}
