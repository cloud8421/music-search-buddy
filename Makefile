CUSTOM_COMPILE_TARGETS := build/CNAME \
													build/fastclick.js
CUSTOM_DIST_TARGETS := dist/CNAME \
											 dist/fastclick.js \
											 dist/200.html

include elm.mk

build/CNAME: CNAME
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp $< $@

dist/CNAME: CNAME
	@echo "${WHITE}[PROD]${RESET} Copying $@"
	@cp $< $@

build/fastclick.js: src/fastclick.js
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp $< $@

dist/fastclick.js: src/fastclick.js
	@echo "${WHITE}[PROD]${RESET} Copying $@"
	@cp $< $@

dist/200.html: index.html
	@echo "${WHITE}[PROD]${RESET} Compiling $@"
	@main_css=/main.min.css main_js=/main.min.js boot_js=/boot.min.js bin/mo index.html > $@

deploy: prod
	@echo "${YELLOW}[PROD]${RESET} Deployment in progress"
	@surge dist
.PHONY: deploy
