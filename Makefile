CUSTOM_COMPILE_TARGETS := build/CNAME build/sw.js
CUSTOM_DIST_TARGETS := dist/CNAME dist/sw.js

include elm.mk

build/CNAME dist/CNAME: CNAME
	cp $< $@

build/sw.js: src/sw.js
	cp $< $@

$(DIST_FOLDER)/sw.js: src/sw.js $(NODE_BIN_DIRECTORY)/uglifyjs
	$(NODE_BIN_DIRECTORY)/uglifyjs --compress --mangle --output $@ -- src/sw.js

deploy: prod
	surge dist
.PHONY: deploy
