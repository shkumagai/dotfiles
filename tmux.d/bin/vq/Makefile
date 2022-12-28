MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CWD := $(dir $(MAKEFILE_PATH))


define create-window-no-venv
	/bin/bash $(CWD)/create-window 0 $1 $2
endef

define create-window-use-venv
	/bin/bash $(CWD)/create-window 1 $1 $2
endef


.PHONY: help
help:
	echo $(CWD)


.PHONY: init
init:
	$(call create-window-no-venv,sandbox)
	$(call create-window-no-venv,visasq-infra,infra)
