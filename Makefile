all:
	haxe build.hxml

retail:
	rm -rf retail
	mkdir -p retail/build
	haxe build.hxml
	rsync -avzm . ./retail -progress --include='assets/**' --include='test/*' --include='src/*.html' --include='*/' --exclude='*'
	uglifyjs --compress --mangle -- build/main.js > retail/build/main.js
	uglifyjs --compress --mangle -- build/worker.js > retail/build/worker.js

.PHONY: retail
