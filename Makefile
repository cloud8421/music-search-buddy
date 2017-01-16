CUSTOM_COMPILE_TARGETS := build/CNAME \
													build/fastclick.js
CUSTOM_DIST_TARGETS := dist/CNAME \
											 dist/fastclick.js \
											 dist/200.html

include elm.mk

build/CNAME dist/CNAME: CNAME
	cp $< $@

build/fastclick.js dist/fastclick.js: src/fastclick.js
	cp $< $@

dist/200.html: index.html
	main_css=/main.min.css main_js=/main.min.js boot_js=/boot.min.js bin/mo index.html > $@

deploy: prod
	surge dist
.PHONY: deploy
