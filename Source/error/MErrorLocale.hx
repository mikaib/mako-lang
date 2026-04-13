package error;

@:structInit
class MErrorLocale {

    private var _mapping: Map<MErrorKind, String> = [
        MErrorKind.TyperUnificationFailed => "Unification failed between #0 and #1",
        MErrorKind.TyperOccursCheckFailed => "Occurs check failed for #0 in #1"
    ];

    public function getTemplate(kind: MErrorKind): String {
        return _mapping.get(kind);
    }

    public function createMessage(kind: MErrorKind, args: Array<Dynamic>): String {
        var template = getTemplate(kind);
        for (i in 0...args.length) {
            template = StringTools.replace(template, '#${i}', Std.string(args[i]));
        }

        return template;
    }

}
