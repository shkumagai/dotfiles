# .zshenv --- zshenv for Linux environment -*- encoding: utf-8-unix -*-


# Basic pathes
append_path $HOME/bin /sbin
export INFOPATH=$TEXLIVE_HOME/texmf/doc/info:$INFOPATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export MANPATH=/opt/local/man:$TEXLIVE_HOME/texmf/doc/man:$MANPATH

export PERL5LIB=/usr/local/lib
export LD_LIBRARY_PATH=/usr/lib:/usr/lib32:/lib:/usr/local/lib


# Aliases
alias ls='ls --color=auto'


# Additional Commands
alias cmigemo='/usr/bin/cmigemo'
alias emacs='/usr/bin/emacs'


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


# Node.js (nodenv)
eval "$(nodenv init -)"


# Yarn (package management tool for Node)
prepend_path $HOME/.yarn/bin $HOME/.config/yarn/global/node_modules/.bin


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
