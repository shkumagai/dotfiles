# ~/.zshenv

# load global settings
source ~/.zsh.d/zshenv

# pathes
#-------
TEXLIVE_HOME=/usr/local/texlive/2011

export PATH=/opt/local/bin:/opt/local/sbin:$TEXLIVE_HOME/bin/universal-darwin:$PATH
export PATH=$HOME/bin:$PATH

export INFOPATH=$TEXLIVE_HOME/texmf/doc/info:$INFOPATH

export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export MANPATH=/opt/local/man:$TEXLIVE_HOME/texmf/doc/man:$MANPATH

export PERL5LIB=/usr/local/lib


# Language and Character set
#---------------------------
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

# Aliases
#--------
alias ll='ls -l'
alias lf='ls -lF'

alias -g V="| vim -R -"


# Subversion
#-----------
export SVN_EDITOR=/usr/bin/vim


# Git
#----
export GIT_MERGE_AUTOEDIT=no


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
