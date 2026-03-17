package typing;

class MType {

    public static var TMono(get, never): MType;
    public static inline function get_TMono(): MType {
        return new MType();
    }

    private function new() {}

}
