package parsing;
import core.MOption;
import core.MOptionKind;
import lexing.MToken;
import parsing.paths.MVarsPath;
import parsing.paths.MIfPath;
import parsing.paths.MParantPath;
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

typedef ParserPathsList = (ArrayView<MToken>) -> ParserFlowControl;

enum ParserFlowControl {
    PReturnSome(expr: MExpr);
    PReturnEaten;
    PNotParsed;
}

class MParser {

    static var pathsList: Array<ParserPathsList> = [
        MFunctionPath.tryIntoEFunction,
        MVarsPath.tryIntoEVars,
    ];

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
            else if (kind == TParantOpen) depthParent++;
            else if (kind == TParantClose) depthParent--;
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

    public function parseNextExpr(): MOption<MExpr> {
        var flowControl = switch (tokens[0].kind) {
            case TKeyword(KIf):
                MIfPath.intoEIf(tokens);
            case TParantOpen:
                MParantPath.intoEParent(tokens);
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

        for (path in pathsList) {
            var flowControl = path(sentence);

            switch (flowControl) {
                case PReturnSome(val): {
                    return Some(val);
                }
                case PReturnEaten: {
                    return None;
                }
                case PNotParsed:
                    continue;
                }
        }

        if(MOperatorPath.IsOperator(sentence)) {
            var flowControl = MOperatorPath.intoOperationAST(sentence, None);
            switch (flowControl) {
                case PReturnSome(val): {
                    return Some(val);
                }
                default:
                    throw new Exception("Could not parse operator");
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