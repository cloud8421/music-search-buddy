CUSTOM_COMPILE_TARGETS := build/CNAME \
                          build/fastclick.js \
													build/fonts
CUSTOM_DIST_TARGETS := dist/CNAME \
                       dist/fastclick.js \
                       dist/200.html \
											 dist/fonts

include elm.mk

build/CNAME: CNAME
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp $< $@

build/fonts: fonts
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@mkdir -p $@
	@cp $</* $@/

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

dist/fonts: fonts
	@echo "${WHITE}[PROD]${RESET} Copying $@"
	@mkdir -p $@
	@cp $</* $@/

deploy: prod
	@echo "${YELLOW}[PROD]${RESET} Deployment in progress"
	@surge dist
.PHONY: deploy

integration-test: $(NODE_BIN_DIRECTORY)/casperjs
	$(NODE_BIN_DIRECTORY)/casperjs test integration-tests.js --base=$(BASE_URL)
.PHONY: integration-test

$(NODE_BIN_DIRECTORY)/casperjs:
	npm install casperjs
