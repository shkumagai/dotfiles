# .zshenv --- zshenv for Darwin (MacOS) environment -*- encoding: utf-8-unix -*-

# Basic pathes
append_path ${HOME}/bin
prepend_path /usr/local/bin /usr/local/sbin
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export MANPATH=/opt/local/man:$MANPATH
export PERL5LIB=/usr/local/lib

if [ -z "$TEXLIVE_HOME" ]; then
  export INFOPATH=$TEXLIVE_HOME/texmf/doc/info:$INFOPATH
  export MANPATH=$TEXLIVE_HOME/texmf/doc/man:$MANPATH
fi

# Homebrew
[[ -x "/opt/homebrew/bin/brew" ]]       && prepend_path /opt/homebrew/bin
[[ -f $(brew --prefix)/etc/brew-wrap ]] && source $(brew --prefix)/etc/brew-wrap
export HOMEBREW_NO_INSTALL_CLEANUP=1

# MacPorts
[[ -x "/opt/local/bin/port" ]]          && prepend_path /opt/local/bin /opt/local/sbin
[[ -d "/opt/local/share/git/contrib" ]] && prepend_path /opt/local/share/git/contrib/diff-highlight
[[ -d "/opt/local/libexec/gnubin" ]]    && prepend_path /opt/local/libexec/gnubin


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
PIPX_BIN=$HOME/.local/bin
PIPX_ROOT=$HOME/.local/pipx
[[ -d "$PIPX_ROOT" ]] && append_path $PIPX_BIN

# virtualenvwrapper via pipx
if [ -d "$PIPX_ROOT/venvs/virtualenvwrapper" ]; then
  export VIRTUALENVWRAPPER_PYTHON=${PIPX_ROOT}/venvs/virtualenvwrapper/bin/python
  source $PIPX_BIN/virtualenvwrapper.sh
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


# Node.js (nodenv)
which nodenv 2>&1 > /dev/null && eval "$(nodenv init -)"


# Yarn (package management tool for Node)
prepend_path $HOME/.yarn/bin $HOME/.config/yarn/global/node_modules/.bin


# Rust
prepend_path $HOME/.cargo/bin

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
