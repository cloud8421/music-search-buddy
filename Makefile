CUSTOM_COMPILE_TARGETS := build/CNAME
CUSTOM_DIST_TARGETS := dist/CNAME \
											 dist/200.html

include elm.mk

build/CNAME dist/CNAME: CNAME
	cp $< $@

dist/200.html: index.html
	main_css=/main.min.css main_js=/main.min.js boot_js=/boot.min.js bin/mo index.html > $@

deploy: prod
	surge dist
.PHONY: deploy
