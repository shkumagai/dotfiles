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
	$(call create-window-no-venv,infra/visasq-terraform,infra)
	$(call create-window-no-venv,app/visasq,visasq)
	$(call create-window-no-venv,app/app-vq,vq)
	$(call create-window-no-venv,app/app-search,search)
	$(call create-window-no-venv,app/app-expert,expert)
	$(call create-window-no-venv,app/app-direct,direct)
