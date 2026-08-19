#!/bin/zsh
# -*- mode: zsh; encoding: utf-8 -*-

# Language
export LANG=en_US.UTF-8
case ${UID} in
0)
  export LANG=C ;;
esac

# XDG Base Directory Specification
export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

export PATH
export MANPATH

# -U: keep only the first occurrence of each duplicate value
# ref: https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html#index-typeset
# shellcheck disable=SC2034
typeset -U PATH path MANPATH manpath

# Ignore /etc/zprofile, /etc/zshrc, /etc/zlogin, /etc/zlogout
# ref: https://zsh.sourceforge.io/Doc/Release/Files.html
# ref: https://zsh.sourceforge.io/Doc/Release/Options.html#index-GLOBALRCS
setopt no_global_rcs

# path_helper recorder PATH each time it runs, so children shells skip the rest of this block.  This is a workaround for the issue that path_helper is not idempotent.
if [[ -n "${__HOME_ZSHENV_SOURCED-}" ]]; then return; fi
export __HOME_ZSHENV_SOURCED=1

# copied from /etc/zprofile
# system-wide environment settings for zsh(1)
if [[ -x /usr/libexec/path_helper ]]; then
  eval "$(/usr/libexec/path_helper -s)"
fi

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -f /usr/local/bin/brw ]]; then
  eval "$(/usr/local/bin/brew shellenv zsh)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi
# shellcheck disable=SC1091
[[ -f $(brew --prefix)/etc/brew-wrap ]] && source "$(brew --prefix)/etc/brew-wrap"

# Macports
if [[ -f /opt/local/bin/port ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
  export MANPATH="/opt/local/share/man:/opt/local/man:${MANPATH}"
fi

# shellcheck disable=SC1036,SC2206
path=(
  "$XDG_BIN_HOME"(N-/)
  "/etc/profiles/per-user/${USER}/bin"(N-/)
  /run/current-system/sw/bin(N-/)
  ${path}
)


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
