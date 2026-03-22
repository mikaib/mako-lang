package core;

// Non re-allocating Array 'slice'
class ArrayView<T> {
    private var data: Array<T>;
    private var offset: Int;
    public var length: Int;

    public function new(data: Array<T>) {
        this.data = data;
        this.offset = 0;
        this.length = data.length;
    }

    public function get(index: Int):Null<T> {
        if (index < 0 || index >= length) {
            return null;
        }
        return data[offset + index];
    }

    public function set(index:Int, value:T):Null<T> {
        if (index < 0 || index >= length) {
            return null;
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

    public function subslice(start: Int, len: Int): ArrayView<T> {
        if (start < 0 || len < 0 || start + len > length) {
            throw "Index out of bounds";
        }

        var view = new ArrayView<T>(data);
        view.offset = this.offset + start;
        view.length = len;
        return view;
    }

    public function map<U>(f: T -> U): Array<U> {
        var result = new Array<U>();
        for (i in 0...length) {
            result.push(f(get(i)));
        }
        return result;
    }
}