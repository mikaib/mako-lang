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
    : | -> |
    i8 | i16 | i32 | i64 |
    u8 | u16 | u32 | u64 |
    f16 | f32 | f64 |
    public | internal | private |
    const | var | if | else | do | while | for |
    func | break | continue | return

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

### number_List
    number
    | number , number_List

### int_List
    int
    | int , int_List

### float_List
    float
    | float , float_List

### bool_List
    bool
    | bool , bool_List

### string_List
    string
    | string , string_List

### EConst_List
    number_List
    | int_List
    | float_List
    | bool_List
    | string_List

### EConst
    string
    | int
    | float
    | IDENTIFIER
    | bool

### number
    digit number
    | digit

### int
    number

### float
    number
    | number . number

### bool
    true | false

### string_escape_seqeunce
    \r | \n | \t | \\ | \"

### string_content
    ANY_UTF8_CHAR string_content
    | string_escape_seqeunce string_content
    | ε

### string
    " string_content "

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
    | IDENTIFIER

### TYPED_IDENTIFIER
    IDENTIFIER : TYPE

### TYPED_IDENTIFIERS_LIST
    TYPED_IDENTIFIER
    | TYPED_IDENTIFIER , TYPED_IDENTIFIERS_LIST
    | ε

### EBinop
    MExpr BINARY_OPERAND MExpr

### EUnop
    UNARY_OPERAND MExpr
    | MExpr UNARY_OPERAND

### EArrayAccess
    IDENTIFIER [ MExpr ]

### EArrayDecl
    TYPE[] IDENTIFIER = new IDENTIFIER[MExpr]
    | TYPE[] IDENTIFIER = { EConst_List }
    | TYPE[] IDENTIFIER

### EFunction
    IDENTIFIER ( TYPED_IDENTIFIERS_LIST ) MExpr

### EObjectAccess
    MExpr . ECall

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

### EIf
    if MExpr MExpr
    | if MExpr MExpr EElse

### EElse
    else if MExpr MExpr EElse
    | else if MExpr MExpr
    | else MExpr

### AccessSpecifier
    public
    | internal
    | private

### EVars
    AccessSpecifier const : TYPE = MExpr
    | AccessSpecifier var : TYPE = MExpr
    | const : TYPE = MExpr
    | var : TYPE = MExpr
    | AccessSpecifier const = MExpr
    | AccessSpecifier var = MExpr
    | const = MExpr
    | var = MExpr
    | AccessSpecifier const : TYPE
    | AccessSpecifier var : TYPE
    | const : TYPE
    | var : TYPE
    | AccessSpecifier const
    | AccessSpecifier var
    | const
    | var

### ECast
    ( TYPE ) IDENTIFIER

### EBreak
    break

### EContinue
    continue

### MExpr
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
    MExpr
    | MExpr , MExpr_List
