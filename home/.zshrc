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
# Fall back to xterm-256color only when the terminfo for $TERM is missing
# (e.g. xterm-ghostty on a remote host); keep "dumb" terminals as they are.
if [[ "$TERM" != 'dumb' ]] && ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# Aliases
alias ls='ls -G'

# Shell functions and hooks are not inherited by child shells, so they are
# set up here (every interactive shell) instead of ~/.zshenv, which returns
# early in child shells.

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Activate sheldon if available
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi
