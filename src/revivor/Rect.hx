package revivor;

class Rect {
    public var left:Int;
    public var top:Int;
    public var width:Int;
    public var height:Int;

    public var right(get, null):Int;
    public var bottom(get, null):Int;

    public function new(l, t, w, h) {
        left = l;
        top = t;
        width = w;
        height = h;
    }

    inline public function get_right():Int {
        return left + width;
    }

    inline public function get_bottom():Int {
        return top + height;
    }
}
