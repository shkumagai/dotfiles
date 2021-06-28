MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CWD := $(dir $(MAKEFILE_PATH))


define create-window
	/bin/bash $(CWD)/template $1
endef


.PHONY: help
help:
	echo $(CWD)


.PHONY: init
init:
	$(call create-window,sandbox)
	$(call create-window,visasq27)
	$(call create-window,release)
	$(call create-window,app-search)
	$(call create-window,app-vq)
	$(call create-window,shared-apps)
