MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CWD := $(dir $(MAKEFILE_PATH))
.DEFAULT_GOAL := help

# Windows opened by `make init`, as <repository>[,<window name>].
# The window name defaults to the repository path.
WINDOWS := \
  sandbox \
  github.com/visasq/visasq-terraform,tf \
  github.com/visasq/visasq,visasq \
  github.com/visasq/app-clientportal,cp \
  github.com/visasq/app-direct,direct \
  github.com/visasq/app-expert,expert \
  github.com/visasq/app-search,search \
  github.com/visasq/app-vq,vq \
  github.com/visasq/welcome,wlcm \
  github.com/visasq/github-actions,ghact

SCRIPTS := base create-window split-dozen-windows template


.PHONY: all
all: init

.PHONY: help
help:
	echo $(CWD)


.PHONY: init
init:
	for w in $(WINDOWS); do \
	  /bin/bash $(CWD)/create-window 0 "$${w%%,*}" "$${w#*,}" || exit $$?; \
	done

.PHONY: test
test:
	cd $(CWD) && shellcheck -S warning $(SCRIPTS)

# Nothing is generated; windows opened by `init` are left for the user to close.
.PHONY: clean
clean:
	@:
