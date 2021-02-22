# .zshenv --- zshenv for Darwin (MacOS) environment -*- encoding: utf-8-unix -*-


# Basic pathes
export PATH=$PATH:$HOME/bin
export INFOPATH=$TEXLIVE_HOME/texmf/doc/info:$INFOPATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export MANPATH=/opt/local/man:$TEXLIVE_HOME/texmf/doc/man:$MANPATH
export PERL5LIB=/usr/local/lib

# Homebrew
[[ -x "/usr/local/bin/brew" ]]           && export PATH=/usr/local/bin:/usr/local/sbin:$PATH
[[ -f $(brew --prefix)/etc/brew-wrap ]]  && source $(brew --prefix)/etc/brew-wrap
export HOMEBREW_NO_INSTALL_CLEANUP=1

# MacPorts
[[ -x "/opt/local/bin/port" ]]          && export PATH=/opt/local/bin:/opt/local/sbin:$PATH
[[ -d "/opt/local/share/git/contrib" ]] && export PATH=/opt/local/share/git/contrib/diff-highlight:$PATH
[[ -d "/opt/local/libexec/gnubin" ]]    && export PATH=/opt/local/libexec/gnubin:$PATH


# Aliases
if [ -x "/opt/local/libexec/gnubin/ls" ]; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi


# Additional Commands
alias cmigemo='/usr/local/bin/cmigemo'
alias emacs='/usr/local/bin/emacs'


# Python
export WORKON=$HOME/.virtualenvs

if [ -x /usr/local/bin/python -a ! -z /opt/local/bin/python ]; then
    PY_EXEC_ROOT=/usr/local/bin
    SUFFIX=""
elif [ -x /opt/local/bin/python ]; then
    PY_EXEC_ROOT=/opt/local/bin
    SUFFIX="-$(${PY_EXEC_ROOT}/python -V | cut -c 8-10)"
else
    PY_EXEC_ROOT=/usr/bin
    SUFFIX=""
fi

export PY_EXEC_ROOT
export VIRTUALENVWRAPPER_PYTHON=${PY_EXEC_ROOT}/python
source ${PY_EXEC_ROOT}/virtualenvwrapper.sh${SUFFIX}

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

# pipx
[[ -d "$HOME/.local/pipx" ]] && export PATH=$PATH:$HOME/.local/bin


# Node.js (nodenv)
eval "$(nodenv init -)"


# Yarn (package management tool for Node)
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
