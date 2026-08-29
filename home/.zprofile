# -*- encoding: utf-8 -*-
# shellcheck shell=zsh

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
