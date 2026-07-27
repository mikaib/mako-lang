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
import haxe.exceptions.NotImplementedException;
import lexing.MTokenKind;
import parsing.paths.MCallPath;
import haxe.Exception;
import core.MTokenViewTools;
import parsing.paths.MLoopPath;
import core.MAccessLevel;

enum ParserFlowControl {
    PReturnSome(expr: MExpr);
    PReturnEaten;
    PNotParsed;
}

class MParser {
    var tokens: ArrayView<MToken>;

    public function new(_tokens: ArrayView<MToken>) {
        tokens = _tokens;
    }

    public function intoMExpr(): MOption<MExpr> {
        if (tokens.length < 1) {
            return None;
        }

        var expressions = parseTree();
        if (expressions.length > 1) {
            throw new NotImplementedException("expressions length was more then 1");
        }

        return Some(expressions[0]);
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
                MTokenViewTools.expectBack(slice, TSemiColon);
                return slice;
            }
        }
        return input;
    }

    public function parseTree(): MExprList {
        var ast = new MExprList();
        while (tokens.length > 0) {
            var expr = parseNextExpr();
            if (expr.hasValue()) {
                ast.push(expr.unwrap());
            }
            else {
                return ast;
            }
        }

        return ast;
    }

    public function expectExprs(exprCount: Int, customErrorMsg: MOption<String>): Array<MExpr> {
        var exprArr = [];
        for (i in 0...exprCount - 1) {
            var expr = parseNextExpr();
            if (expr.isNone()) {
                if (customErrorMsg.hasValue()) {
                    throw new Exception(customErrorMsg.unwrap());
                }
                throw new Exception('Expected expr, found none');
            }
            exprArr.push(expr.unwrap());
        }

        return exprArr;
    }

    public function parseNextExpr(): MOption<MExpr> {
        var flowControl = switch (tokens[0].kind) {
            case TKeyword(KIf):
                MIfPath.intoEIf(tokens);
            case TParentOpen:
                MParentPath.intoEParent(tokens);
            case TKeyword(KReturn):
                MReturnPath.intoEReturn(tokens);
            case TBraceOpen:
                var block = MParseBlocker.createBlock(tokens, Some(TBraceOpen), TBraceClose);
                MBlockPath.intoEBlock(block);
            default:
                PNotParsed;
        }

        switch (flowControl) {
            case PReturnSome(val): return Some(val);
            case _: null;
        }

        if(tokens[0].kind.match(TKeyword(KWhile))
            || tokens[0].kind.match(TKeyword(KDo))
            || tokens[0].kind.match(TKeyword(KFor))
        ) {
            var flowControl = MLoopPath.intoLoop(tokens);
            switch (flowControl) {
                case PReturnSome(val): return Some(val);
                default: throw new Exception("Could not parse loop");
            }
        }

        var sentence = splitSentence(tokens);
        if (sentence.length == 0) {
            return None;
        }

        if (MCallPath.isFuncCall(sentence)) {
            var flowControl = MCallPath.parseFuncCall(sentence);
            switch (flowControl) {
                case PReturnSome(val): {
                    return Some(val);
                }
                default:
                    throw new Exception("Could not parse call");
            }
        }

        trace(sentence.map(t -> '${t.kind}'));

        final accessSpecifier = switch sentence[0].kind {
            case TKeyword(KPublic): sentence.consume(1); APublic;
            case TKeyword(KProtected): sentence.consume(1); AProtected;
            case TKeyword(KPrivate): sentence.consume(1); APrivate;
            default: APrivate;
        };

        var control: MOption<ParserFlowControl> = switch sentence[0].kind {
            case TKeyword(KFunc): Some(MFunctionPath.intoEFunction(sentence, accessSpecifier));
            case TKeyword(KVar): Some(MVarsPath.intoEVars(sentence, accessSpecifier));
            case TKeyword(KConst): Some(MVarsPath.intoEVars(sentence, accessSpecifier));
            default: None;
        };

        if (control.hasValue()){
            var flowControl = control.unwrap();
            switch (flowControl) {
                case PReturnSome(val): return Some(val);
                default: throw new Exception("Parse was unsuccessfull");
            }
        }

        if(MOperatorPath.IsOperator(sentence)) {
            var flowControl = MOperatorPath.intoOperationAST(sentence, None);
            switch (flowControl) {
                case PReturnSome(val): return Some(val);
                default: throw new Exception("Could not parse operator");
            }
        }

        if (sentence.length == 1 && sentence[0].kind.match(TConst(_))) {
            var flowControl = MConstPath.IntoEConst(sentence);
            switch (flowControl) {
                case PReturnSome(val): return Some(val);
                default: null;
            }
        }

        trace('Not all tokens could be parsed: ${tokens.map(t -> '${t.kind}, ')}');
        return None;
    }
}