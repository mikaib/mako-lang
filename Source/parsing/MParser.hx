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
import lexing.MTokenKind.MTokenKeyword;
import lexing.MTokenKind;
import parsing.paths.MCallPath;
import core.MTokenViewTools;
import parsing.paths.MLoopPath;
import core.MAccessLevel;
import error.MErrorKind;

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

    private function splitSentence(input: ArrayView<MToken>): ArrayView<MToken> {
        var readIndex = 0;
        var depthBrace = 0;
        var depthParent = 0;
        while (readIndex < input.length) {
            var kind = input[readIndex].kind;
            readIndex++;

            if (kind == TBraceOpen) depthBrace++;
            else if (kind == TBraceClose) depthBrace--;
            else if (kind == TParentOpen) depthParent++;
            else if (kind == TParentClose) depthParent--;
            else if (kind == TSemiColon && depthBrace == 0 && depthParent == 0) {
                var slice = input.subslice(0, readIndex);
                input.consume(readIndex);
                MTokenViewTools.expectBack(slice, TSemiColon, context);
                return slice;
            }
        }
        return input;
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (tokens.length > 0) {
            switch parseNextExpr() {
                case PReturnSome(e): ast.push(e);
                default: return ast;
            }
        }

        return ast;
    }

    public function expectExprs(exprCount: Int): MOption<MExprList> {
        var exprArr = [];
        for (i in 0...exprCount - 1) {
            var exprControl = parseNextExpr();
            switch exprControl {
                case PReturnSome(e): exprArr.push(e);
                default: return None;
            }
        }

        return Some(exprArr);
    }

    public function parseNextExpr(): ParserFlowControl {
        var optionExpr: MOption<ParserFlowControl> = switch (tokens[0].kind) {
            case TKeyword(KIf):
                Some(MIfPath.intoEIf(tokens, context));
            case TParentOpen:
                Some(MParentPath.intoEParent(tokens, context));
            case TKeyword(KReturn):
                Some(MReturnPath.intoEReturn(tokens, context));
            case TBraceOpen:
                var block = MParseBlocker.createBlock(tokens, Some(TBraceOpen), TBraceClose);
                Some(MBlockPath.intoEBlock(block, context));
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
            return MLoopPath.intoLoop(tokens, context);
        }

        var sentence = splitSentence(tokens);
        if (sentence.length == 0) {
            return PParseError;
        }

        if (MCallPath.isFuncCall(sentence)) {
            return MCallPath.parseFuncCall(sentence, context);
        }

        final accessSpecifier = switch sentence[0].kind {
            case TKeyword(KPublic): sentence.consume(1); APublic;
            case TKeyword(KProtected): sentence.consume(1); AProtected;
            case TKeyword(KPrivate): sentence.consume(1); APrivate;
            default: APrivate;
        };

        var control: MOption<ParserFlowControl> = switch sentence[0].kind {
            case TKeyword(KFunc): Some(MFunctionPath.intoEFunction(sentence, accessSpecifier, context));
            case TKeyword(KVar): Some(MVarsPath.intoEVars(sentence, accessSpecifier, context));
            case TKeyword(KConst): Some(MVarsPath.intoEVars(sentence, accessSpecifier, context));
            default: None;
        };

        if (control.hasValue()){
            return control.unwrap();
        }

        if(MOperatorPath.IsOperator(sentence)) {
            return MOperatorPath.intoOperationAST(sentence, None, context);
        }

        if (sentence.length == 1 && sentence[0].kind.match(TConst(_))) {
            return MConstPath.IntoEConst(sentence, context);
        }

        trace('Not all tokens could be parsed: ${tokens.map(t -> '${t.kind}, ')}');
        context.emitError(MErrorKind.ParserUnparsedTokens, tokens.intoArray());
        return PParseError;
    }
}