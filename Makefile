CUSTOM_COMPILE_TARGETS := build/CNAME
CUSTOM_DIST_TARGETS := dist/CNAME

include elm.mk

build/CNAME dist/CNAME: CNAME
	cp $< $@

deploy: prod
	surge dist
.PHONY: deploy
