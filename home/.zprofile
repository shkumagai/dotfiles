#!/bin/zsh
# -*- shellcheck shell=zsh; encoding: utf-8 -*-

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
