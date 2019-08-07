package revivor;

import haxe.ui.components.*;
import haxe.ui.containers.*;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import js.Browser.document;

class Main {
    public var image:Image;
    public var output:TextArea;
    public var frames:Array<Frame> = [];
    public var selectedFrame:Frame = null;
    public var exporter:Exporter = new ExporterJson();

    static function main() {
        new Main();
    }

    public function new() {
        Toolkit.init();
        var vbox = new VBox();
        {
            var hbox = new HBox();
            var button = new Button();
            button.text = "Open";
            button.onClick = function(m) {
                open();
            };
            hbox.addComponent(button);
            var button = new Button();
            button.text = "Generate";
            button.onClick = function(m) {
                generate();
            };
            hbox.addComponent(button);
            vbox.addComponent(hbox);
        }
        {
            var hbox = new HBox();
            image = new Image();
            image.resource = "../test/megaman.png";
            var imageView = new ScrollView();
            imageView.addComponent(image);
            imageView.onClick = onImageClick;
            imageView.height = 512;
            imageView.width = 512;
            hbox.addComponent(imageView);
            var scroll = new ScrollView();
            hbox.addComponent(scroll);
            output = new TextArea();
            output.width = 400;
            output.height = 400;
            // output.style.fontSize = 10;
            hbox.addComponent(output);
            vbox.addComponent(hbox);
        }
        Screen.instance.addComponent(vbox);
        {
            document.getElementById('input').addEventListener('change', onFileOpen, false);
        }
    }

    public function open() {
        document.getElementById('input').click();
    }

    private function onFileOpen(evt) {
        var files = evt.target.files;
        var f = files[0];
        var reader = new js.html.FileReader();
        reader.onload = (function(theFile) {
            return function(e) {
                image.resource = e.target.result;
            };
        })(f);
        reader.readAsDataURL(f);
    }

    private function generate() {
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        var canvas:Dynamic = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
        var generator = new Generator(ctx, frames);
        generator.process();
        output.text = exporter.export(frames);
    }

    private function onImageClick(e:haxe.ui.core.MouseEvent) {
        var container = e.target;
        var x = e.screenX - container.screenLeft;
        var y = e.screenY - container.screenTop;

        var index = 0;
        for(frame in frames) {
            var rect = frame.rect;

            if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) {
                selectedFrame = frame;
                trace(frame);
                trace("frame" + index);
                break;
            }

            index++;
        }
    }
}
