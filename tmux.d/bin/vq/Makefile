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
	$(call create-window-use-venv,visasq-shared-apps,shared)
	$(call create-window-use-venv,visasq,vis-asq)
	$(call create-window-use-venv,app-vq)
	$(call create-window-use-venv,app-search,app-srh)
	$(call create-window-use-venv,app-advisor,app-adv)
	$(call create-window-no-venv,visasq-batch,batch)
	$(call create-window-no-venv,visasq-batch-infra,bth-inf)
	$(call create-window-no-venv,visasq-infra,infra)
