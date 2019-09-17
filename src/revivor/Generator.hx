package revivor;

import js.Browser.document;

class SubImageData {
    private var imageData:js.html.ImageData;
    private var startX:Int;
    private var startY:Int;
    public var width:Int;
    public var height:Int;

    public function new(imageData, ox, oy, w, h) {
        this.imageData = imageData;
        startX = ox;
        startY = oy;
        width = w;
        height = h;
    }

    inline public function isSamePixelColor(color:Array<Int>, x, y) {
        var p = (imageData.width * (startY + y) + startX + x) * 4;
        var d = imageData.data;
        return d[p] == color[0] && d[p + 1] == color[1] && d[p + 2] == color[2] && d[p + 3] == color[3];
    }
}

class Generator {
    var imageData:js.html.ImageData;
    var results:Array<Frame>;
    var rects:Array<Rect>;
    var backgroundColor:Array<Int>;
    var onComplete:Array<Frame>->Void;
    var abort:Bool = false;

    public function new(imageData, bgcolor) {
        this.imageData = imageData;
        this.backgroundColor = bgcolor;
    }

    public function process(onComplete:Array<Frame>->Void) {
        rects = [];
        results = [];
        this.onComplete = onComplete;

        for(y in 0...imageData.height) {
            for(x in 0...imageData.width) {
                processFrom(x, y);
            }
        }

        end();
    }

    public function cancel() {
        abort = true;
    }

    function end() {
        for(rect in rects) {
            var f = new Frame(rect);
            results.push(f);
        }

        onComplete(results);
    }

    function processFrom(x, y) {
        var it = 0;
        var rect = new Rect(x, y, 2, 2);

        if(overlap(rect)) {
            return;
        }

        while(it < 100) {
            var w:Int = cast rect.width;
            var h:Int = cast rect.height;
            var subData = new SubImageData(imageData, cast rect.left, cast rect.top, w, h);
            var found = true;

            for(i in 0...w) {
                if(!subData.isSamePixelColor(backgroundColor, i, 0)) {
                    rect.top--;
                    rect.height++;
                    found = false;
                    break;
                }
            }

            for(i in 0...w) {
                if(!subData.isSamePixelColor(backgroundColor, i, h - 1)) {
                    rect.height++;
                    found = false;
                    break;
                }
            }

            for(i in 0...h) {
                if(!subData.isSamePixelColor(backgroundColor, 0, i)) {
                    rect.left--;
                    rect.width++;
                    found = false;
                    break;
                }
            }

            for(i in 0...h) {
                if(!subData.isSamePixelColor(backgroundColor, w - 1, i)) {
                    rect.width++;
                    found = false;
                    break;
                }
            }

            ++it;

            if(found) {
                if(!overlap(rect)) {
                    if(isFullBackground(subData)) {
                        return;
                    } else {
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

    function isFullBackground(data:SubImageData) {
        for(y in 0...data.height) {
            for(x in 0...data.width) {
                if(!data.isSamePixelColor(backgroundColor, x, y)) {
                    return false;
                }
            }
        }

        return true;
    }

    function overlap(rect:Rect):Bool {
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
