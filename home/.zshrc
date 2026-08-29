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

# Activate sheldon if available
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi
