# ~/.zshenv

# load global settings
source ~/.zsh.d/zshenv


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


# Erlang
#-------
if [ -d /opt/local/erlang ]; then
    typeset -a ERLANG_VERSION
    ERLANG_VERSION=(R15B01
                    R15B02
                    R15B03-1
                    R16A
                    R16B
                    R16B02
    )
    PATH=/opt/local/erlang/${ERLANG_VERSION[6]}/bin:$PATH
    export PATH
fi


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
