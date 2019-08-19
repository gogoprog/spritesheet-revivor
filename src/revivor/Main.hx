package revivor;

import haxe.ui.components.*;
import haxe.ui.containers.*;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import js.Browser.document;

class Main {
    public var image:Image;
    public var output:TextArea;
    public var frames:Array<Frame> = [];
    public var selectedFrame:Frame = null;
    public var exporter:Exporter = new ExporterJson();
    public var imageCanvas:js.html.CanvasElement;

    static function main() {
        new Main();
    }

    public function new() {
        Toolkit.init();
        Toolkit.theme = "native";
        var app = new HaxeUIApp();
        app.ready(function() {
            var main:Component = ComponentMacros.buildComponent("assets/main.xml");
            app.addComponent(main);
            image = main.findComponent("image");
            var imageView:ScrollView = main.findComponent("imageView", null, true);
            imageView.onClick = onImageClick;
            var button:Button = main.findComponent("importButton", null, true);
            button.onClick = function(m) {
                open();
            };
            var button:Button = main.findComponent("demoButton", null, true);
            button.onClick = function(m) {
                openFile("../test/megaman.png");
            };
            output = main.findComponent("output", null, true);
            output.disabled = true;
            app.start();
        });
        document.getElementById('input').addEventListener('change', onFileOpen, false);
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
                openFile(e.target.result);
            };
        })(f);
        reader.readAsDataURL(f);
    }

    private function openFile(filePath) {
        image.resource = filePath;
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        img.style.visibility = "visible";
        haxe.Timer.delay(generate, 100);
    }

    private function generate() {
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        var canvas:Dynamic = document.createElement("canvas");
        imageCanvas = canvas;
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
        var generator = new Generator(ctx, frames);
        generator.process();
        output.text = exporter.export(frames);
        img.style.visibility = "hidden";
        image.element.appendChild(canvas);
        drawQuads();
    }

    private function drawCanvas() {
        var canvas = imageCanvas;
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        var ctx:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        ctx.clearRect(0, 0, img.width, img.height);
        ctx.drawImage(img, 0, 0);
    }

    private function onImageClick(e:haxe.ui.core.MouseEvent) {
        var container = e.target;
        var x = e.screenX - container.screenLeft;
        var y = e.screenY - container.screenTop;
        var index = 0;

        for(frame in frames) {
            var rect = frame.rect;

            if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) {
                selectFrame(frame);
                break;
            }

            index++;
        }
    }

    private function drawQuads() {
        var ctx = imageCanvas.getContext2d();
        ctx.globalCompositeOperation = "source-over";
        ctx.globalAlpha = 1;
        ctx.strokeStyle = "#AAAAAA";
        ctx.setLineDash([5, 3]);

        for(frame in frames) {
            var rect = frame.rect;
            ctx.strokeRect(rect.left, rect.top, rect.width, rect.height);
        }
    }

    private function selectFrame(frame:Frame) {
        drawCanvas();
        drawQuads();
        selectedFrame = frame;
        var ctx = imageCanvas.getContext2d();
        ctx.strokeStyle = "#000000";
        var rect = frame.rect;
        ctx.strokeRect(rect.left, rect.top, rect.width, rect.height);
    }
}
