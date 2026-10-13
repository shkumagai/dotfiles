# -*- encoding: utf-8 -*-
# shellcheck shell=zsh

# in ~/.zshenv, executed `unsetopt GLOBAL_RCS` and ignored /etc/zshrc
if [[ -r /etc/zshrc ]]; then
  source /etc/zshrc
fi

umask 022

if [[ "$TERM" != 'dumb' ]]; then
  stty -ixon -ixoff
fi

# Environment variables
export TERM=xterm-256color

# Aliases
alias ls='ls -G'

# Shell functions and hooks are not inherited by child shells, so they are
# set up here (every interactive shell) instead of ~/.zshenv, which returns
# early in child shells.

# Homebrew: brew-file wrapper
if [[ -n "${HOMEBREW_PREFIX-}" && -f "${HOMEBREW_PREFIX}/etc/brew-wrap" ]]; then
  source "${HOMEBREW_PREFIX}/etc/brew-wrap"
fi

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Activate sheldon if available
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi
