package lexing;

import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import core.MChar;

class MLexer {

    private var readPos: Int;

    private function peek(input: String): Option<MChar> {

        throw new NotImplementedException("peek not implemented yet");
    }

    private function readChar(input: String): Int {
        throw new NotImplementedException("readChar not implemented yet");
    }

    private function readToken(input: String): MToken {
        throw new NotImplementedException("readToken not implemented yet");
    }

    public function lexTokens(input: String): Array<MToken> {

        return [];
    }

}
