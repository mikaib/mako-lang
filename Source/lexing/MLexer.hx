package lexing;

import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import core.MChar;
import core.MTokenTools;

class MLexer {

    private var readPos: Int;

    private function peek(input: String): Option<MChar> {
        if (input.length > readPos + 1) {
            return None;
        }
        
        return Some(input.charCodeAt(readPos + 1));
    }

    private function readChar(input: String): Option<MChar> {
        if (input.length > readPos + 1) {
            return None;
        }

        return Some(input.charCodeAt(++readPos));
    }

    public function lexTokens(input: String): Array<MToken> {
        var currentStringBuf: StringBuf = "";
        var currentTokens: Array<MToken> = [];

        do {
            var char: MChar = readChar(input);
            if (char != None) {
                currentStringBuf.addChar(char);
                var token: MToken = MTokenTools.tokenFromString(currentStringBuf.toString());
                if (token != None) {
                    currentTokens.push(token);
                    currentStringBuf = "";
                }
            }
        } while (char != None);
        return currentTokens;
    }

}
