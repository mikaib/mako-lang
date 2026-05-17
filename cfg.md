# This document describes the syntax of the language as a context free grammar (cfg)

## G = (V, T, P, S)

## V (Variables)
    1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | 
    a | A | b | B | c | C | d | D | e | E | f | F |
    g | G | h | H | i | I | j | J | k | K | l | L |
    m | M | n | N | o | O | p | P | q | Q | r | R |
    s | S | t | T | u | U | v | V | w | W | x | X |
    y | Y | z | Z | _ |
    ( | ) | { | } | [ | ] |
    + | - | * | / | ! | % | << | >> | ++ | -- | = | == | += | -= | 
    : | ->
    i8 | i16 | i32 | i64
    u8 | u16 | u32 | u64
    f16 | f32 | f64

## T (Terminals)

### lower_case_letter
    a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z

### upper_case_letter
    A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z

### letter
    lower_case_letter 
    | upper_case_leter

### digit
    1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0

### number
    digit number
    | digit

### IDENTIFIER
    letter identifier_inner

### identifier_inner
    letter identifier_inner
    | number identifier_inner 
    | _ identifier_inner 
    | ε

### BINARY_OPARAND
    + | - | / | * | % | == | != | > | >= | < 
    | <= | || | && | | | & | ^ | << | >> |+= 
    | -= | *= | /= | ^= | |= | &=

### UNARY_OPARAND
    ++ | -- | ! | ~

### TYPE
    i8 | i16 | i32 | i64 
    | u8 | u16 | u32 | u64
    | f16 | f32 | f64

### TYPED_IDENTIFIER
    IDENTIFIER : TYPE

### TYPED_IDENTIFIERS_LIST
    TYPED_IDENTIFIER ε
    | TYPED_IDENTIFIER , TYPED_IDENTIFIERS_LIST ε

### EBinop
    MExpr BINARY_OPERAND MExpr

### EUnop
    UNARY_OPERAND MExpr

### EArrayAccess
    ???

### EArrayDecl
    ???

### EFunction
    IDENTIFIER ( TYPED_IDENTIFIERS_LIST ) MExpr

### EObjectAccess
    ECall . ECall

### ECall
    IDENTIFIER ( MExpr_List )

### EParenthesis
    ( MExpr )

### EBlock
    { TODO }

### EWhile
    do MExpr while MExpr

### EFor
    for ( MExpr ; MExpr ; MExpr ) MExpr

### EReturn
    return MExpr

### MExpr :=
    EBinop
    | EUnop
    | EArrayAccess
    | EArrayDecl
    | EFunction
    | EObjectAccess
    | ECall
    | EParenthesis
    | EBlock
    | EWhile
    | EFor
    | EReturn
    | EIf
    | EVars
    | EConst
    | ECast
    | EBreak
    | EContinue

### MExpr_List
    MExpr ε
    | MExpr , MExpr_List ε
