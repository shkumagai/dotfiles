#!/bin/zsh
# -*- mode: zsh; encoding: utf-8 -*-

# in ~/.zshenv, executed `unsetopt GLOBAL_RCS` and ignored /etc/zshrc
if [[ -r /etc/zshrc ]]; then
  source /etc/zshrc
fi

umask 022

if [[ "$TERM" != 'dumb' ]]; then
  stty -ixon -ixoff
fi

# Corrections
# shellcheck disable=SC2034
CORRECT_IGNORE='_*'
# shellcheck disable=SC2034
CORRECT_IGNORE_FILE='.*'

# History
HISTSIZE=10000
# shellcheck disable=SC2034
SAVEHIST=10000
if [[ -d "XDG_STATE_HOME/zsh" ]]; then
  HISTFILE="${XDG_STATE_HOME}/zsh/history"
else
  HISTFILE="${HOME}/.zsh_history"
fi

# Use emacs key bindings
bindkey -e

# Activate sheldon if available
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon init zsh)"
fi


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
