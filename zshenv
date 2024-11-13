# ~/.zshenv

# ignore /etc/profile
setopt no_global_rcs

# load global settings
source ~/.zsh.d/zshenv-common.sh
case ${OSTYPE} in
    darwin*) ENVFILE=~/.zsh.d/zshenv-darwin.sh ;;
    linux*)  ENVFILE=~/.zsh.d/zshenv-linux.sh  ;;
esac
# echo "PATH (HOME/zshenv after) :: ${PATH}"
source $ENVFILE


# Language and Character set
#---------------------------
export LANG=en_US.UTF-8
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
