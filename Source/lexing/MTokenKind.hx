package lexing;

import core.MConst;

enum MTokenKind {
    TSlash;
    TConst(const: MConst);
}
