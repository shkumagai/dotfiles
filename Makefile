.SILENT: help test

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

export XDG_BIN_HOME := $(HOME)/.local/bin
export XDG_CONFIG_HOME := $(HOME)/.config
export MISE_GLOBAL_CONFIG_FILE := $(abspath home/.config/mise/config.toml)
export HOMEBRW_BUNDLE_FILE_GLOBAL := $(abspath home/.config/homebrew/Brewfile)

ifeq ($(shell uname -s),Darwin)
	ifeq ($(shell uname -m),arm64)
		HOMEBREW := /opt/homebrew/bin/brew
	else
		HOMEBREW := /usr/local/bin/brew
	endif
else
	HOMEBREW := /home/linuxbrew/.linuxbrew/bin/brew
endif

MISE := $(shell command -v mise 2>/dev/null || echo "$(HOME)/.local/bin/mise")

.PHONY: help
help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all
all: install

$(XDG_BIN_HOME):
	mkdir -p $@

$(XDG_CONFIG_HOME):
	mkdir -p $@

$(MISE):
	curl -fsSL https://mise.run | sh

.PHONY: bootstrap
bootstrap: | $(MISE) ## Run mise bootstrap whole steps.
	$(MISE) bootstrap --force-dotfiles --yes -C $(HOME)/.dotfiles

.PHONY: apply-dotfiles
apply-dotfiles: | $(MISE) ## Apply dotfiles to home directory.
	$(MISE) bootstrap dotfiles apply

.PHONY: apply-repos
apply-repos: | $(MISE) ## Clone repository that required.
	$(MISE) bootstrap repos apply --yes --skip-dirty

$(HOMEBREW):
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.ONESHELL: bundle
.PHONY: bundle
bundle: | $(HOMEBREW) ## Install and upgrade all dependencies based on home/.config/homebrew/Brewfile.
	$(HOMEBREW) bundle install --global

.PHONY: install
install : bundle bootstrap ## Run install

.PHONY: clean-dotfiles
clean-dotfiles: | $(MISE) ## Clean up dotfiles.
	$(MISE) bootstrap dotfiles unapply

.PHONY: test
test: ## Run checkmake.
	checkmake Makefile
	shellcheck install.sh
