CUSTOM_COMPILE_TARGETS := build/CNAME

include elm.mk

build/CNAME: CNAME
	cp $< $@

deploy:
	surge build
.PHONY: build
