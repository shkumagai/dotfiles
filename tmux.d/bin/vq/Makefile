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


.PHONY: launch-large
launch-large:
	# create new window
	tmux new-window "launch"
	tmux split-pane -h

	# split panes
	tmux select-pane -t 0
	tmux split-pane -v
	tmux split-pane -v
	tmux split-pane -v
	tmux split-pane -v

	tmux resize-pane -t 0 -y 28
	tmux resize-pane -t 1 -y 8
	tmux resize-pane -t 2 -y 8
	# tmux resize-pane -t 5 -y 30
	tmux resize-pane -t 4 -y 8

	tmux select-pane -t 5
	tmux split-pane -v
	tmux split-pane -v
	tmux split-pane -v
	tmux split-pane -v
	tmux split-pane -v

	tmux resize-pane -t 5 -y 21
	tmux resize-pane -t 6 -y 8
	tmux resize-pane -t 7 -y 21
	tmux resize-pane -t 8 -y 8
	tmux resize-pane -t 9 -y 21

	# send keys to change directory
	tmux send-keys -t 0 "cd ~/work/gh/corp/app/visasq" C-m
	tmux send-keys -t 1 "cd ~/work/gh/corp/app/visasq/webapp-admin" C-m
	tmux send-keys -t 2 "cd ~/work/gh/corp/app/visasq/webapp-admin2" C-m
	tmux send-keys -t 3 "cd ~/work/gh/corp/app/app-vq" C-m
	tmux send-keys -t 4 "cd ~/work/gh/corp/app/app-vq/front/webapp" C-m

	tmux send-keys -t 5 "cd ~/work/gh/corp/app/app-expert" C-m
	tmux send-keys -t 6 "cd ~/work/gh/corp/app/app-expert/webapp" C-m
	tmux send-keys -t 7 "cd ~/work/gh/corp/app/app-direct" C-m
	tmux send-keys -t 8 "cd ~/work/gh/corp/app/app-direct/webapp" C-m
	tmux send-keys -t 9 "cd ~/work/gh/corp/app/app-search" C-m
	tmux send-keys -t 10 "cd ~/work/gh/corp/app/visasq-batch/auth0-token-parser" C-m

	# select first pane
	tmux select-pane -t 0

# .PHONY: launch-small
# launch-small:
# 	# create new window
# 	tmux new-window server
# 	tmux split-pane -v
# 	tmux split-pane -v
# 	tmux split-pane -v
# 	tmux split-pane -v

# 	tmux select-pane -t 0
# 	tmux split-pane -h
