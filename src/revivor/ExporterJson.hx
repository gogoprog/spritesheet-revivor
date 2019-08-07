package revivor;

class ExporterJson implements Exporter {
    public function new() {}

    public function export(frames:Array<Frame>):String {
        var index = 0;
        var content:Dynamic = {};
        content.frames = [];

        for(frame in frames) {
            var rect = frame.rect;
            var obj:Dynamic = {};
            obj.filename = "frame" + index;
            obj.frame = {
                x: rect.left,
                y: rect.top,
                w: rect.width,
                h: rect.height
            };
            obj.spriteSourceSize = {
                x: 0,
                y: 0,
                w: rect.width,
                h: rect.height
            };
            obj.sourceSize = {
                w: rect.width,
                h: rect.height
            };
            content.frames.push(obj);
            index++;
        }

        return haxe.Json.stringify(content, "  ");
    }
}
