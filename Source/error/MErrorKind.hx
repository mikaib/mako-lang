package error;

enum abstract MErrorKind(String) to String {
    ///Parser errors
    public var ParserUnexpectedToken = "parser.unexpectedToken";
    public var ParserUnexpectedStreamEnd = "parser.unexpectedStreamEnd";
    public var ParserInvalidExpr = "parser.invalidExpr";
    public var ParserMissingClosingParenthesis = "parser.missingClosingParenthesis";
    public var ParserMissingClosingBrace = "parser.missingClosingBrace";
    public var ParserMissingClosingBracket = "parser.missingClosingBracket";
    public var ParserExpectedTypedParam = "parser.expectedTypedParameter";
    public var ParserExpectedFunctionName = "parser.expectedFunctionName";
    public var ParserExpectedMethodCall = "parser.parserExpectedMethodCall";
    public var ParserExpectedIfCondition = "parser.expectedFunctionIfCondition";
    public var ParserExpectedIfExpression = "parser.expectedIfExpression";
    public var ParserDoWhileExpectedExpr = "parser.doWhileExpectedExpr";
    public var ParserDoWhileExpectedCondition = "parser.doWhileExpectedCondition";
    public var ParserExpectedBinaryOperator = "parser.expectedBinaryOperator";
    public var ParserExpectedUnaryOperator = "parser.expectedUnaryOperator";
    public var ParserExpectedExprInParenthesis = "parser.expectedExprInParenthesis";
    public var ParserExpectedStreamEnd = "parser.expectedStreamEnd";
    public var ParserExpectedVariableName = "parser.expectedVariableName";
    public var ParserUnparsedTokens = "parser.unparsedTokens";
    public var ParserExpectedConst = "parser.expectedConst";
    public var ParserExpectedFunctionArgumentName = "parser.expectedFunctionArgumentName";
    public var ParserExpectedFunctionArgColon = "parser.expectedFunctionArgumentColon";
    public var ParserExpectedFunctionReturnType = "parser.expectedFunctionReturnType";
    public var ParserExpectedVariableType = "parser.expectedVariableType";

    ///Typer errors
    public var TyperUnificationFailed = "typer.unificationFailed";
    public var TyperOccursCheckFailed = "typer.occursCheckFailed";
    public var TyperInvalidScope = "typer.invalidScope";
}
