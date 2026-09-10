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
	$(call create-window-no-venv,github.com/visasq/visasq-terraform,tf)
	$(call create-window-no-venv,github.com/visasq/visasq,visasq)
	$(call create-window-no-venv,github.com/visasq/app-clientportal,cp)
	$(call create-window-no-venv,github.com/visasq/app-direct,direct)
	$(call create-window-no-venv,github.com/visasq/app-expert,expert)
	$(call create-window-no-venv,github.com/visasq/app-search,search)
	$(call create-window-no-venv,github.com/visasq/app-vq,vq)
	$(call create-window-no-venv,github.com/visasq/welcome,wlcm)
	$(call create-window-no-venv,github.com/visasq/github-actions,ghact)
