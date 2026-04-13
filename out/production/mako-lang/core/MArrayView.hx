package core;

// Non re-allocating Array 'slice'
@:structInit
private class ArrayViewData<T> {
    public var data: Array<T>;
    public var offset: Int;
    public var length: Int;
}

abstract ArrayView<T>(ArrayViewData<T>) from ArrayViewData<T> to ArrayViewData<T> {

    public var length(get, never): Int;
    private inline function get_length(): Int {
        return this.length;
    }

    public function new(data: Array<T>) {
        this = {
            data: data,
            offset: 0,
            length : 0
        };
    }

    @:arrayAccess
    public function get(index: Int):Null<T> {
        if (index < 0 || index >= this.length) {
            return null;
        }
        return this.data[this.offset + index];
    }

    public function consume(n: Int): ArrayView<T> {
        if (n < 0 || n > this.length) {
            throw "Index out of bounds";
        }

        this.offset += n;
        this.length -= n;
        return this;
    }

    public function subslice(start: Int, len: Int): ArrayView<T> {
        if (start < 0 || len < 0 || start + len > this.length) {
            throw "Index out of bounds";
        }

        var view: ArrayViewData<T> = new ArrayView<T>(this.data);
        view.offset = this.offset + start;
        view.length = len;
        return view;
    }

    public function map<U>(f: T -> U): Array<U> {
        var result = new Array<U>();
        for (i in 0...this.length) {
            result.push(f(get(i)));
        }
        return result;
    }
}