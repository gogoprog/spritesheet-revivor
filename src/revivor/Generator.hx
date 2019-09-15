package revivor;

import haxe.ui.util.Rectangle;
import js.Browser.document;

class Generator {
    var ctx:js.html.CanvasRenderingContext2D;
    var results:Array<Frame>;
    var rects:Array<Rectangle>;
    var backgroundColor:Array<Int>;

    public function new(ctx, results, bgcolor) {
        this.ctx = ctx;
        this.results = results;
        this.backgroundColor = bgcolor;
    }

    public function process() {
        rects = [];

        for(y in 0...ctx.canvas.height) {
            for(x in 0...ctx.canvas.width) {
                processFrom(x, y);
            }
        }

        // :TODO: Sort?

        for(rect in rects) {
            var f = new Frame(rect);
            results.push(f);
        }
    }

    function processFrom(x, y) {
        var it = 0;
        var rect = new Rectangle(x, y, 2, 2);

        if(overlap(rect)) {
            return;
        }

        while(it < 100) {
            var w:Int = cast rect.width;
            var h:Int = cast rect.height;
            var data = ctx.getImageData(rect.left, rect.top, w, h);
            var found = true;

            for(i in 0...w) {
                var p = i * 4;

                if(!isBackground(data.data, p)) {
                    rect.top--;
                    rect.height++;
                    found = false;
                    break;
                }
            }

            for(i in 0...w) {
                var p = (w * (h - 1) * 4) + i * 4;

                if(!isBackground(data.data, p)) {
                    rect.height++;
                    found = false;
                    break;
                }
            }

            for(i in 0...h) {
                var p = w * i * 4;

                if(!isBackground(data.data, p)) {
                    rect.left--;
                    rect.width++;
                    found = false;
                    break;
                }
            }

            for(i in 0...h) {
                var p = w * i * 4 + (w - 1) * 4;

                if(!isBackground(data.data, p)) {
                    rect.width++;
                    found = false;
                    break;
                }
            }

            ++it;

            if(found) {
                if(!overlap(rect)) {
                    if(isFullBackground(data)) {
                        return;
                        // continue;
                    } else {
                        // debugDraw(data, rect.left, rect.top);
                        rects.push(rect);
                        return;
                    }
                } else {
                    return;
                }
            }
        }
    }

    inline function isBackground(data:Dynamic, p) {
        return data[p] == backgroundColor[0] && data[p + 1] == backgroundColor[1] && data[p + 2] == backgroundColor[2] && data[p + 3] == backgroundColor[3];
    }

    function isFullBackground(data:js.html.ImageData) {
        var w = data.width;

        for(y in 0...data.height) {
            for(x in 0...data.width) {
                var p = (w * y * 4) + x * 4;

                if(!isBackground(data.data, p)) {
                    return false;
                }
            }
        }

        return true;
    }

    function overlap(rect:Rectangle):Bool {
        for(other in rects) {
            if(rect.left > other.right || other.left > rect.right) {
                continue;
            }

            if(rect.top > other.bottom || other.top > rect.bottom) {
                continue;
            }

            return true;
        }

        return false;
    }

    function debugDraw(data, x, y) {
        var canvas:js.html.CanvasElement = cast document.getElementById("debug");
        canvas.getContext2d().putImageData(data, x, y);
    }
}
