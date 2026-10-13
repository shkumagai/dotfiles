.SILENT: help test

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

export XDG_BIN_HOME := $(HOME)/.local/bin
export XDG_CONFIG_HOME := $(HOME)/.config
export MISE_GLOBAL_CONFIG_FILE := $(abspath home/.config/mise/config.toml)

MISE := $(shell command -v mise 2>/dev/null || echo "$(HOME)/.local/bin/mise")

.PHONY: help
help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all
all: install

$(MISE):
	curl -fsSL https://mise.run | sh

.PHONY: bootstrap
bootstrap: | $(MISE) ## Run mise bootstrap whole steps at once.
	$(MISE) bootstrap --force-dotfiles --yes -C $(HOME)/.dotfiles

.PHONY: macos-defaults
macos-defaults: | $(MISE) ## Apply MacOS Defaults configuration.
	$(MISE) bootstrap macos defaults

.PHONY: packages
packages: | $(MISE) ## Install packages from [bootstrap.packages].
	$(MISE) bootstrap packages apply

.PHONY: dotfiles
dotfiles: | $(MISE) ## Apply dotfiles to home directory.
	$(MISE) bootstrap dotfiles apply

.PHONY: repos
repos: | $(MISE) ## Clone repository that required.
	$(MISE) bootstrap repos apply --yes --skip-dirty

.PHONY: install
install : bootstrap ## Run install

.PHONY: clean-dotfiles
clean-dotfiles: | $(MISE) ## Clean up dotfiles.
	$(MISE) bootstrap dotfiles unapply

.PHONY: clean
clean: clean-dotfiles

.PHONY: check
check: ## Verify changed files (static / consistency / runtime / security).
	scripts/check.sh

.PHONY: check-all
check-all: ## Verify every tracked file.
	scripts/check.sh --all

.PHONY: test
test: ## Run checkmake.
	checkmake Makefile
	shellcheck install.sh
