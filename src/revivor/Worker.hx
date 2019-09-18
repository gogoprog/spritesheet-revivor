package revivor;

class Worker {
    static function main() {
        new Worker();
    }

    private var workerScope:js.html.DedicatedWorkerGlobalScope;

    public function new() {
        workerScope = untyped self;
        workerScope.onmessage = onMessage;
    }

    private function onMessage(e) {
        var generator = new Generator(e.data.imageData, e.data.backgroundColor);
        generator.process(function(frames) {
            workerScope.postMessage(frames);
        });
    }
}
