#!/bin/zsh
# .zshenv --- zshenv for Darwin (MacOS) environment -*- encoding: utf-8-unix -*-
# shellcheck disable=SC1071,SC1091

# Basic pathes
append_path "${HOME}/bin"
prepend_path /usr/local/bin
prepend_path /usr/local/sbin
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export MANPATH=/opt/local/man:$MANPATH
export PERL5LIB=/usr/local/lib

if [ -z "$TEXLIVE_HOME" ]; then
  export INFOPATH=$TEXLIVE_HOME/texmf/doc/info:$INFOPATH
  export MANPATH=$TEXLIVE_HOME/texmf/doc/man:$MANPATH
fi

# Homebrew
[[ -x "/opt/homebrew/bin/brew" ]] && append_path /opt/homebrew/bin
[[ -f $(brew --prefix)/etc/brew-wrap ]] && source "$(brew --prefix)/etc/brew-wrap"
export HOMEBREW_NO_INSTALL_CLEANUP=1

# MacPorts
if [ -x "/opt/local/bin/port" ]; then
  append_path /opt/local/bin
  append_path /opt/local/sbin
fi
[[ -d "/opt/local/share/git/contrib" ]] && append_path /opt/local/share/git/contrib/diff-highlight
# pyenv において GNU coreutils 等を利用する際に /opt/local/libexec/gnubin を
# PATHに含めると Python 3.12 以降のビルドが失敗する事象がある模様
# [[ -d "/opt/local/libexec/gnubin" ]] && prepend_path /opt/local/libexec/gnubin


# Aliases
if [ -x "/opt/local/libexec/gnubin/ls" ]; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi


# Conditional Settings
if [ -d "/opt/local/share/fzf" ]; then
  source /opt/local/share/fzf/shell/key-bindings.zsh
  source /opt/local/share/fzf/shell/completion.zsh
fi


# Python
# pipx
PIPX_BIN="${HOME}/.local/bin"
PIPX_ROOT="${HOME}/.local/pipx"
[[ -d "$PIPX_ROOT" ]] && append_path "${PIPX_BIN}"

# virtualenvwrapper via pipx
if [ -d "$PIPX_ROOT/venvs/virtualenvwrapper" ]; then
  export VIRTUALENVWRAPPER_PYTHON="${PIPX_ROOT}/venvs/virtualenvwrapper/bin/python"
  # shellcheck disable=SC1091
  source "${PIPX_BIN}/virtualenvwrapper.sh"
fi

# Workaround: PycURL install helper
export PYCURL_SSL_LIBRARY=openssl

if [ -d /opt/local/lib/openssl ]; then
  LDFLAGS=-L/opt/local/lib
  CPPFLAGS=-I/opt/local/include
elif [ -d /usr/local/opt/openssl ]; then
  LDFLAGS=-L/usr/local/opt/openssl/lib
  CPPFLAGS=-I/usr/local/opt/openssl/include
fi
export LDFLAGS
export CPPFLAGS

# Workaround: mysqlclient
PKG_CONFIG_PATH=/opt/local/lib/mysql57/pkgconfig
export PKG_CONFIG_PATH

# Temporary: pyenv
PYENV_ROOT=${HOME}/.pyenv
[[ -d "${PYENV_ROOT}/bin" ]] && prepend_path "${PYENV_ROOT}/bin"
eval "$(pyenv init -)"


# Node.js (nodenv)
if [ -n "$(command -v nodenv)" ] && [ -d "$(nodenv root)" ] && [ ! $(echo "$PATH" | grep ".nodenv/shims") ]; then
  eval "$(nodenv init -)"
fi


# Yarn (package management tool for Node)
prepend_path "${HOME}/.yarn/bin" "${HOME}/.config/yarn/global/node_modules/.bin"


# Rust
prepend_path "${HOME}/.cargo/bin"


# Google Cloud SDK
source "${HOME}/google-cloud-sdk/completion.zsh.inc"
prepend_path "${HOME}/google-cloud-sdk/bin"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
