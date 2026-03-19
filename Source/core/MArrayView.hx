package core;

// Non re-allocating Array 'slice'
class ArrayView<T> {
    public var data: Array<T>;
    public var offset: Int;
    public var length: Int;

    public function new(data: Array<T>) {
        this.data = data;
        this.offset = 0;
        this.length = data.length;
    }

    @:arrayAccess
    public function get(index: Int): T {
        if (index < 0 || index >= length) {
            throw "Index out of bounds";
        }
        return data[offset + index];
    }

    @:arrayAccess
    public function set(index:Int, value:T):T {
        if (index < 0 || index >= length) {
            throw "Index out of bounds";
        }

        data[offset + index] = value;
        return value;
    }

    public function consume(n: Int): ArrayView<T> {
        if (n < 0 || n > length) {
            throw "Index out of bounds";
        }

        offset += n;
        length -= n;
        return this;
    }
}