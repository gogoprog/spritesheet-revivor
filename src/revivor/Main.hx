package revivor;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.TextArea;
import haxe.ui.components.Button;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Screen;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.events.MouseEvent;
import js.Browser.document;

class Main {
    private var image:Image;
    private var label:Label;
    private var output:TextArea;
    private var frames:Array<Frame> = [];
    private var selectedFrame:Frame = null;
    private var exporter:Exporter = new ExporterJson();
    private var imageCanvas:js.html.CanvasElement;
    private var pickingBackground:Bool = false;
    private var pickBGButton:Button;
    private var backgroundColor:Array<Int> = [ 0, 0, 0, 0 ];
    private var worker:js.html.Worker;

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
            label = main.findComponent("label");
            var imageView:ScrollView = main.findComponent("imageView", null, true);
            imageView.onClick = onImageClick;
            imageView.registerEvent(MouseEvent.MOUSE_MOVE, onImageMouseMove);
            var button:Button = main.findComponent("importButton", null, true);
            button.onClick = function(m) {
                open();
            };
            var button:Button = main.findComponent("demoButton", null, true);
            button.onClick = function(m) {
                openFile("../test/megaman.png");
            };
            var button:Button = main.findComponent("pickBGButton", null, true);
            pickBGButton = button;
            button.onClick = function(m) {
                pickingBackground = true;
                stopWorker();
            };
            output = main.findComponent("output", null, true);
            /* cast(output.element, js.html.TextAreaElement).readOnly = true; */
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
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        img.onload = function(e) { setup(); pickBGFromPixel(0, 0); generate(); };
        img.style.visibility = "visible";
        image.resource = filePath;
    }

    private function setup() {
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        var canvas:Dynamic;
        frames = [];

        if(imageCanvas == null) {
            canvas = document.createElement("canvas");
        } else {
            canvas = imageCanvas;
        }

        imageCanvas = canvas;
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
    }

    private function generate() {
        var ctx:js.html.CanvasRenderingContext2D = imageCanvas.getContext("2d");
        var fullData = ctx.getImageData(0, 0, imageCanvas.width, imageCanvas.height);
        setupWorker();
        worker.postMessage({imageData: fullData, backgroundColor:backgroundColor});
    }

    private function drawCanvas() {
        var canvas = imageCanvas;
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        var ctx:js.html.CanvasRenderingContext2D = canvas.getContext("2d");
        ctx.clearRect(0, 0, img.width, img.height);
        ctx.drawImage(img, 0, 0);
    }

    private function onImageClick(e:haxe.ui.events.MouseEvent) {
        var container = e.target;
        var x = e.screenX - container.screenLeft;
        var y = e.screenY - container.screenTop;

        if(pickingBackground) {
            pickBGFromPixel(x, y);
            generate();
        } else {
            var index = 0;

            for(frame in frames) {
                var rect:Rect = frame.rect;

                if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) {
                    selectFrame(frame);
                    trace('Selected frame ${index}');
                    break;
                }

                index++;
            }
        }
    }
    private function onImageMouseMove(e:haxe.ui.events.MouseEvent) {
        var container = e.target;
        var x = e.screenX - container.screenLeft;
        var y = e.screenY - container.screenTop;
        var index = 0;

        for(frame in frames) {
            var rect:Rect = frame.rect;

            if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) {
                label.text = 'frame${index}';
                return;
            }

            index++;
        }

        label.text = '';
    }

    private function pickBGFromPixel(x, y) {
        var imageData = imageCanvas.getContext2d().getImageData(x, y, 1, 1);
        var data = imageData.data;
        backgroundColor[0] = data[0];
        backgroundColor[1] = data[1];
        backgroundColor[2] = data[2];
        backgroundColor[3] = data[3];
        pickBGButton.element.style.backgroundColor = Util.getColorString(data[0], data[1], data[2], data[3]);
        pickBGButton.element.style.color = Util.getColorString(255 - data[0], 255 - data[1], 255 - data[2], 255);
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

    private function setupWorker() {
        var e = image.element.firstElementChild;
        var img:js.html.ImageElement = cast e;
        worker = new js.html.Worker("../build/worker.js");
        worker.onmessage = function(e) {
            frames = e.data;
            output.text = exporter.export(frames);
            img.style.visibility = "hidden";
            image.element.appendChild(imageCanvas);
            drawQuads();
            document.getElementById("loading").style.display = "none";
        };
        document.getElementById("loading").style.display = "block";
    }

    private function stopWorker() {
        if(worker != null) {
            worker.terminate();
        }

        document.getElementById("loading").style.display = "none";
    }
}
