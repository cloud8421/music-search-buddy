.PHONY: install server watch clean test help
ELM_ENTRY = src/Main.elm
ELM_FILES = $(shell find src -type f -name '*.elm' 2>/dev/null)
NODE_BIN_DIRECTORY = node_modules/.bin
DEVD_VERSION = 0.7
WELLINGTON_VERSION = 1.0.4
MODD_VERSION = 0.4
ELM_TEST_VERSION = 0.18.2
UGLIFY_JS_VERSION = 2.7.4
OS := $(shell uname)
BUILD_FOLDER = build
DIST_FOLDER = dist
INSTALL_TARGETS = src bin $(BUILD_FOLDER) \
									$(BUILD_FOLDER)/images \
									Makefile \
									elm-package.json \
									src/Main.elm src/State.elm src/Types.elm src/View.elm \
									src/boot.js styles/main.scss index.html \
									images \
									bin/modd modd.conf \
									bin/devd bin/wt \
									bin/mo \
									.gitignore \
									$(CUSTOM_INSTALL_TARGETS)
COMPILE_TARGETS = $(BUILD_FOLDER) \
									$(BUILD_FOLDER)/main.js \
									$(BUILD_FOLDER)/main.css \
									$(BUILD_FOLDER)/index.html \
									$(BUILD_FOLDER)/boot.js \
									$(BUILD_FOLDER)/images/*.jpg \
									$(BUILD_FOLDER)/images/*.png \
									$(BUILD_FOLDER)/images/*.ico \
									$(CUSTOM_COMPILE_TARGETS)
DIST_TARGETS = $(DIST_FOLDER) \
							 $(DIST_FOLDER)/images/*.jpg \
							 $(DIST_FOLDER)/images/*.png \
							 $(DIST_FOLDER)/images/*.ico \
							 $(DIST_FOLDER)/main.min.js \
							 $(DIST_FOLDER)/boot.min.js \
							 $(DIST_FOLDER)/main.min.css \
							 $(DIST_FOLDER)/index.html \
							 $(CUSTOM_DIST_TARGETS)
TEST_TARGETS = $(NODE_BIN_DIRECTORY)/elm-test tests/Main.elm
SERVER_OPTS = -w $(BUILD_FOLDER) -l $(BUILD_FOLDER)/ -f /index.html $(CUSTOM_SERVER_OPTS)

MO_URL = "https://raw.githubusercontent.com/tests-always-included/mo/master/mo"
ifeq ($(OS),Darwin)
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-osx64.tgz"
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_darwin_amd64.tar.gz"
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
else
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-linux64.tgz"
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_linux_amd64.tar.gz"
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
endif

#COLORS
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
					 %help; \
					 while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
					 print "usage: make [target]\n\n"; \
					 for (sort keys %help) { \
					 print "${WHITE}$$_:${RESET}\n"; \
					 for (@{$$help{$$_}}) { \
					 $$sep = " " x (32 - length $$_->[0]); \
					 print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
					 }; \
					 print "\n"; }

all: $(COMPILE_TARGETS) ## Compiles project files

install: $(INSTALL_TARGETS) ## Installs prerequisites and generates file/folder structure

server: ## Runs a local server for development
	@echo "${WHITE}[DEV]${RESET} Start dev server"
	@bin/devd $(SERVER_OPTS)

watch: ## Watches files for changes, runs a local dev server and triggers live reload
	@echo "${WHITE}[DEV]${RESET} Start dev watcher"
	@bin/modd

clean: ## Removes compiled files and build artifacts
	@echo "${WHITE}[BUILD]${RESET} Remove build files"
	@rm -rf $(BUILD_FOLDER)/*
	@rm -rf elm-stuff/build-artifacts
	@echo "${WHITE}[PROD]${RESET} Remove build files"
	@rm -rf $(DIST_FOLDER)/*
	@echo "${WHITE}[TEST]${RESET} Remove build files"
	@rm -rf tests/elm-stuff/build-artifacts

test: $(TEST_TARGETS) ## Runs unit tests via elm-test
	@echo "${WHITE}[TEST]${RESET} Running elm-test"
	@$(NODE_BIN_DIRECTORY)/elm-test

prod: $(DIST_TARGETS) ## Minifies build folders for production usage

help: ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

$(BUILD_FOLDER) $(BUILD_FOLDER)/images $(DIST_FOLDER) $(DIST_FOLDER)/images bin src styles images:
	@echo "${WHITE}[SETUP]${RESET} Creating $@"
	@mkdir -p $@

Makefile:
	@echo "${WHITE}[SETUP]${RESET} Creating Makefile"
	@test -s $@ || echo "$$Makefile" > $@

styles/main.scss: styles
	@echo "${WHITE}[SETUP]${RESET} Creating $@"
	@test -s $@ || touch $@

src/Main.elm: src
	@test -s $@ || (echo "$$main_elm" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

src/State.elm: src
	@test -s $@ || (echo "$$state_elm" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

src/Types.elm: src
	@test -s $@ || (echo "$$types_elm" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

src/View.elm: src
	@test -s $@ || (echo "$$view_elm" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

src/boot.js: src
	@test -s $@ || (echo "$$boot_js" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

tests/Main.elm:
	@$(NODE_BIN_DIRECTORY)/elm-test init --yes && echo "${WHITE}[SETUP]${RESET} Creating $@"

index.html:
	@test -s $@ || (echo "$$index_html" > $@ && echo "${WHITE}[SETUP]${RESET} Creating $@")

bin/devd:
	@echo "${WHITE}[SETUP]${RESET} Installing $@"
	@curl ${DEVD_URL} -L -o $@.tgz
	@tar -xzf $@.tgz -C bin/ --strip 1
	@rm $@.tgz

bin/wt:
	@echo "${WHITE}[SETUP]${RESET} Installing $@"
	@curl ${WELLINGTON_URL} -L -o $@.tgz
	@tar -xzf $@.tgz -C bin/
	@rm $@.tgz

bin/modd:
	@echo "${WHITE}[SETUP]${RESET} Installing $@"
	@curl ${MODD_URL} -L -o $@.tgz
	@tar -xzf $@.tgz -C bin/ --strip 1
	@rm $@.tgz

bin/mo:
	@echo "${WHITE}[SETUP]${RESET} Installing $@"
	@curl $(MO_URL) -L -o $@
	@chmod +x $@

modd.conf:
	@echo "${WHITE}[SETUP]${RESET} Creating $@"
	@echo "$$modd_config" > $@

elm-package.json:
	@echo "${WHITE}[SETUP]${RESET} Creating $@"
	@echo "$$elm_package_json" > $@

$(NODE_BIN_DIRECTORY)/elm-test:
	@echo "${WHITE}[SETUP]${RESET} Installing elm-test"
	@npm install elm-test@${ELM_TEST_VERSION}

$(NODE_BIN_DIRECTORY)/uglifyjs:
	@echo "${WHITE}[SETUP]${RESET} Installing uglify.js" 
	@npm install uglify-js@${UGLIFY_JS_VERSION}

.gitignore:
	@echo "${WHITE}[SETUP]${RESET} Creating $@"
	@echo "$$gitignore" > $@

$(BUILD_FOLDER)/main.css: styles/*.scss
	@echo "${WHITE}[BUILD]${RESET} Compiling $@"
	@bin/wt compile -b $(BUILD_FOLDER)/ styles/main.scss

$(BUILD_FOLDER)/main.js: $(ELM_FILES)
	@echo "${WHITE}[BUILD]${RESET} Compiling $@"
	@elm make $(ELM_ENTRY) --yes --warn --debug --output $@

$(BUILD_FOLDER)/boot.js: src/boot.js
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp $? $@

$(BUILD_FOLDER)/index.html: index.html
	@echo "${WHITE}[BUILD]${RESET} Compiling $@"
	@main_css=/main.css main_js=/main.js boot_js=/boot.js bin/mo index.html > $@

$(BUILD_FOLDER)/images/%.jpg $(BUILD_FOLDER)/images/%.png $(BUILD_FOLDER)/images/%.ico:
	@echo "${WHITE}[BUILD]${RESET} Copying $@"
	@cp -r images/ $(BUILD_FOLDER)/images/

$(DIST_FOLDER)/main.min.css: styles/*.scss
	@echo "${WHITE}[PROD]${RESET} Compiling $@"
	@bin/wt compile -s compressed -b $(DIST_FOLDER)/ styles/main.scss
	@mv $(DIST_FOLDER)/main.css $@

$(DIST_FOLDER)/main.js: $(ELM_FILES)
	@echo "${WHITE}[PROD]${RESET} Compiling $@"
	@elm make $(ELM_ENTRY) --yes --warn --output $@

$(DIST_FOLDER)/main.min.js: $(DIST_FOLDER)/main.js $(NODE_BIN_DIRECTORY)/uglifyjs
	@echo "${WHITE}[PROD]${RESET} Minifying $@"
	@$(NODE_BIN_DIRECTORY)/uglifyjs --compress --mangle --output $@ -- $(DIST_FOLDER)/main.js
	@rm $(DIST_FOLDER)/main.js

$(DIST_FOLDER)/boot.min.js: src/boot.js $(NODE_BIN_DIRECTORY)/uglifyjs
	@echo "${WHITE}[PROD]${RESET} Minifying $@"
	@$(NODE_BIN_DIRECTORY)/uglifyjs --compress --mangle --output $@ -- src/boot.js

$(DIST_FOLDER)/index.html: index.html
	@echo "${WHITE}[PROD]${RESET} Compiling $@"
	@main_css=/main.min.css main_js=/main.min.js boot_js=/boot.min.js bin/mo index.html > $@

$(DIST_FOLDER)/images/%.jpg $(DIST_FOLDER)/images/%.png $(DIST_FOLDER)/images/%.ico:
	@cp -r images/ $(DIST_FOLDER)/images/

define Makefile

include elm.mk
endef
export Makefile

define modd_config
src/**/*.elm {
  prep: make $(BUILD_FOLDER)/main.js
}
src/**/*.js {
  prep: make $(BUILD_FOLDER)/boot.js
}
styles/**/*.scss {
  prep: make $(BUILD_FOLDER)/main.css
}
index.html {
  prep: make $(BUILD_FOLDER)/index.html
}
$(BUILD_FOLDER)/** {
  daemon: make server
}
endef
export modd_config

define types_elm
module Types exposing (..)


type Msg
    = NoOp


type alias Model =
    Int
endef
export types_elm

define state_elm
module State exposing (..)

import Types exposing (..)

init : ( Model, Cmd Msg )
init = 0 ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp -> model ! []
endef
export state_elm

define view_elm
module View exposing (..)

import Html exposing (div, text, Html)
import Types exposing (..)


root : Model -> Html Msg
root model =
    div []
        [ model |> toString |> text ]
endef
export view_elm

define main_elm
module Main exposing (..)

import Html
import Platform.Sub as Sub
import Types exposing (..)
import State
import View


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , view = View.root
        , update = State.update
        , subscriptions = subscriptions
        }
endef
export main_elm

define elm_package_json
{
    "version": "1.0.0",
    "summary": "helpful summary of your project, less than 80 characters",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "source-directories": [
        "src",
        "test"
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "elm-lang/html": "2.0.0 <= v < 3.0.0",
        "elm-lang/http": "1.0.0 <= v < 2.0.0"
    },
    "elm-version": "0.18.0 <= v < 0.19.0"
}
endef
export elm_package_json

define boot_js
window.onload = function() {
  var app = Elm.Main.fullscreen();
};
endef
export boot_js

define index_html
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Elm Project</title>
  <link rel="stylesheet" href="{{main_css}}">
</head>
<body>
</body>
  <script type="text/javascript" src="{{main_js}}"></script>
  <script type="text/javascript" src="{{boot_js}}"></script>
</html>
endef
export index_html

define gitignore
elm-stuff
elm.js
/$(BUILD_FOLDER)/*
/bin/*
endef
export gitignore
