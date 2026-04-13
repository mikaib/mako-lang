package error;

enum abstract MErrorKind(String) to String {
    public var TyperUnificationFailed = "typer.unificationFailed";
    public var TyperOccursCheckFailed = "typer.occursCheckFailed";
    public var TyperInvalidScope = "typer.invalidScope";
}
