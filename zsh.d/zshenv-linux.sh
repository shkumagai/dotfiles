# .zshenv --- zshenv for Linux environment -*- encoding: utf-8-unix -*-


# Basic pathes
TEXLIVE_HOME=/usr/local/texlive/2011
PATH=/opt/local/bin:/opt/local/sbin:$TEXLIVE_HOME/bin/x86_64-linux:$PATH

export PATH=$HOME/bin:$PATH:/sbin
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
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7
export WORKON=$HOME/.virtualenvs
source /usr/bin/virtualenvwrapper.sh


# Golang
export GOENVGOROOT=${HOME}/.goenvs
export GOENVTARGET=${HOME}/bin
export GOENVHOME=${HOME}/workspace
export GOPATH=$HOME/work/golang
export PATH=$GOPATH/bin:$PATH


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
