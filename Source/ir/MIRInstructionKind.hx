package ir;

enum MIRInstructionKind {
    Add; // Add #a #b
    Cast; // Cast #a #type
    Return; // Return #a
    Call; // Call #function #arg1 #arg2 ...
}
