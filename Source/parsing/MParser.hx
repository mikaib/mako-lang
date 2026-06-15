package parsing;
import core.MOption;
import core.MOptionKind;
import lexing.MToken;
import parsing.paths.MVarsPath;
import parsing.paths.MIfPath;
import parsing.paths.MParentPath;
import parsing.paths.MReturnPath;
import parsing.paths.MConstPath;
import parsing.paths.MOperatorPath;
import parsing.paths.MFunctionPath;
import parsing.paths.MBlockPath;
import core.MArrayView.ArrayView;
import core.MExprTools;
import lexing.MTokenKind.MTokenKeyword;
import lexing.MTokenKind;
import parsing.paths.MCallPath;
import parsing.paths.MLoopPath;
import core.MAccessLevel;
import error.MErrorKind;
import core.MConst;
import haxe.macro.Expr.Constant;
import parsing.paths.MObjectAccessPath;
using haxe.EnumTools.EnumValueTools;

enum ParserFlowControl {
    PReturnSome(expr: MExpr);
    PParseError;
}

class MParser {
    var context: Context;
    var tokens: ArrayView<MToken>;

    public function new(_tokens: ArrayView<MToken>, _context: Context) {
        tokens = _tokens;
        context = _context;
    }

    public function intoMExpr(): MOption<MExpr> {
        if (tokens.length < 1) {
            context.emitError(MErrorKind.ParserUnexpectedStreamEnd, tokens.intoArray());
            return None;
        }

        return switch parseNextExpr() {
            case PReturnSome(e): Some(e);
            default: return None;
        }
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (tokens.length > 0) {
            switch parseNextExpr() {
                case PReturnSome(e): {
                    ast.push(e);
                    consumeTerminator(e);
                }
                default: return ast;
            }
        }

        return ast;
    }

    public function consumeTerminator(expr: MExpr) {
        final next = tokens.peek();
        final hasSemi = next != null && next.kind.match(TSemiColon);

        if (MExprTools.endsWithBlock(expr)) {
            if (hasSemi) {
                tokens.consume(1); // permitted but not required after a block
            }
            return;
        }

        if (hasSemi) {
            tokens.consume(1);
            return;
        }

        context.emitError(MErrorKind.ParserExpectedSemicolon, tokens.intoArray());
        recoverToTerminator();
    }

    function recoverToTerminator() {
        while (true) {
            final t = tokens.peek();
            if (t == null || t.kind.match(TBraceClose)) {
                return;
            }
            if (t.kind.match(TSemiColon)) {
                tokens.consume(1);
                return;
            }
            tokens.consume(1);
        }
    }

    public function parseNextExpr(): ParserFlowControl {
        switch parseNextPrimaryExpr() {
            case PReturnSome(expr): {
                if (tokens.peek() == null) {
                    return PReturnSome(expr);
                }

                switch tokens.peek().kind {
                    case TTokenOperator(_): return MOperatorPath.intoBinOpExpr(tokens, expr, None, context, this);
                    case TDot: return MObjectAccessPath.intoObjectAccess(expr, tokens, context, this);
                    case _: return PReturnSome(expr);
                }
            }
            case PParseError: return PParseError;
        }
    }

    public function parseNextPrimaryExpr(): ParserFlowControl {
        if (tokens.length == 0) {
            return PParseError;
        }
        // operators should already be handles by intoBinOpExpr in parseNextExpr or are invalid at this point.
        // e.g. * y should start with an expression, not an operator
        // ++x is valid, and should be parsed by an unop
        if (tokens.peek().kind.match(TTokenOperator(_))) {
            return MOperatorPath.intoUnOpExpr(tokens, None, context, this);
        }

        var expr = switch parseNextPrimaryExprInternal() {
            case PReturnSome(e): e;
            case PParseError: return PParseError;
        }

        var nextToken = tokens.peek();
        if (nextToken == null) {
            return PReturnSome(expr);
        }

        if (MOperatorPath.isPostfixUnop(nextToken.kind)) {
            return MOperatorPath.intoUnOpExpr(tokens, Some(expr), context, this);
        }

        return PReturnSome(expr);
    }

    private function parseNextPrimaryExprInternal(): ParserFlowControl {
        var optionExpr: MOption<ParserFlowControl> = switch (tokens[0].kind) {
            case TKeyword(KIf):
                Some(MIfPath.intoEIf(tokens, context, this));
            case TParentOpen:
                Some(MParentPath.intoEParent(tokens, context, this));
            case TKeyword(KReturn):
                Some(MReturnPath.intoEReturn(tokens, context, this));
            case TBraceOpen:
                Some(MBlockPath.intoEBlock(tokens, context, this));
            default:
                None;
        }

        if (optionExpr.hasValue()) {
            return optionExpr.unwrap();
        }

        if(tokens[0].kind.match(TKeyword(KWhile))
            || tokens[0].kind.match(TKeyword(KDo))
            || tokens[0].kind.match(TKeyword(KFor))
        ) {
            return MLoopPath.intoLoop(tokens, context, this);
        }

        var funcCall: MOption<ParserFlowControl> = None;
        switch tokens[0].kind {
            case TConst(CIdent(_)):
                if (tokens[1].kind.match(TParentOpen)) {
                    funcCall = Some(MCallPath.parseFuncCall(tokens, context, this));
                }
            case _:
        }

        if (funcCall.hasValue()) {
            return funcCall.unwrap();
        }

        final accessSpecifier = switch tokens.peek().kind {
            case TKeyword(KPublic): tokens.consume(1); APublic;
            case TKeyword(KProtected): tokens.consume(1); AProtected;
            case TKeyword(KPrivate): tokens.consume(1); APrivate;
            default: APrivate;
        };

        var control: MOption<ParserFlowControl> = switch tokens.peek().kind {
            case TKeyword(KFunc): Some(MFunctionPath.intoEFunction(tokens, accessSpecifier, context, this));
            case TKeyword(KVar): Some(MVarsPath.intoEVars(tokens, accessSpecifier, context, this));
            case TKeyword(KConst): Some(MVarsPath.intoEVars(tokens, accessSpecifier, context, this));
            default: None;
        };

        if (control.hasValue()){
            return control.unwrap();
        }

        if (tokens.peek().kind.match(TConst(_))) {
            return MConstPath.IntoEConst(tokens, None, context);
        }

        /*

        if(MOperatorPath.IsOperator(sentence)) {
            return MOperatorPath.intoOperationAST(sentence, None, context, this);
        }

        trace('Not all tokens could be parsed: ${tokens.map(t -> '${t.kind}, ')}');
        context.emitError(MErrorKind.ParserUnparsedTokens, tokens.intoArray());
         */
        return PParseError;
    }
}