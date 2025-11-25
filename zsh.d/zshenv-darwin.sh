#!/bin/zsh
# .zshenv --- zshenv for Darwin (MacOS) environment -*- encoding: utf-8-unix -*-
# shellcheck disable=SC1071,SC1091

# Basic paths
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

# mise
if [ -s "${HOME}/.local/bin/mise" ]; then
  eval "$(${HOME}/.local/bin/mise activate zsh)"
fi

# MacPorts
if [ -x "/opt/local/bin/port" ]; then
  append_path /opt/local/bin
  append_path /opt/local/sbin
fi
[[ -d "/opt/local/share/git/contrib" ]] && append_path /opt/local/share/git/contrib/diff-highlight


# Aliases
if [ -x "/opt/local/libexec/gnubin/ls" ]; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi
alias bastion-prod='gcloud compute ssh --zone "us-central1-a" "bastion-prod-gce" --tunnel-through-iap --project "service-vis-asq-v2-prod"'

# fzf
if [ -n "$(command -v fzf)" ]; then
  source <(fzf --zsh)
  source ${HOME}/.zsh.d/src/fzf-git.sh
fi

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


# Rust
prepend_path "${HOME}/.cargo/bin"


# Google Cloud SDK
source "$(mise where gcloud)/completion.zsh.inc"
CLOUDSDK_PYTHON=/opt/local/bin/python3.12
export CLOUDSDK_PYTHON
GOOGLE_CLOUD_PROJECT="private-shoji-kumagai-01"
GOOGLE_CLOUD_LOCATION="us-central1"

# Claude code
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION="us-east5"
export ANTHROPIC_VERTEX_PROJECT_ID="private-shoji-kumagai-01"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
