MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CWD := $(dir $(MAKEFILE_PATH))


define create-window
	/bin/bash $(CWD)/create-window $1 $2
endef


.PHONY: help
help:
	echo $(CWD)


.PHONY: init
init:
	$(call create-window,sandbox)
	$(call create-window,visasq-shared-apps,shared)
	$(call create-window,visasq,vis-asq)
	$(call create-window,app-vq)
	$(call create-window,app-search,app-srh)
	$(call create-window,app-advisor,app-adv)
	$(call create-window,visasq-batch)
	$(call create-window,visasq-batch-infra)
	$(call create-window,visasq-infra)
