#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -U compinit && compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0


#===========================================================
# Customize
#===========================================================

# Language and Character set
#---------------------------
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

# Pathes
#-------
PATH=$HOME/bin:$PATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
export LD_LIBRARY_PATH=/usr/lib:/usr/lib32:/lib:/usr/local/lib


# Aliases
#--------
system=$(uname -s)
if [ 'Linux' = "$system" ]; then
  alias ls='ls --color=auto'
elif [ 'SunOS' = "$system" ]; then
  # nothing to do
else
  alias ls='ls -G'
fi
alias ll='ls -l'
alias lf='ls -lF'

alias -g V="| vim -R -"


# Prompts
#--------
autoload -U colors
colors
case ${UID} in
0)
  PROMPT="%B%{${fg[red]}%}[%T %m:/]#%{${reset_color}%}%b "
  PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
  RPROMPT="%{${fg[red]}%}[%~]%{${reset_color}%}"
  SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
  ;;
*)
  PROMPT="%{${fg[cyan]}%}[%T %n@%m]%%%{${reset_color}%} "
  PROMPT2="%{${fg[cyan]}%}%_>%{${reset_color}%} "
  RPROMPT="%{${fg[cyan]}%}[%~]%{${reset_color}%}"
  SPROMPT="%{${fg[cyan]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
  ;;
esac


# Automation
#-----------

setopt auto_cd
setopt auto_pushd

setopt auto_list
setopt pushd_ignore_dups
setopt list_packed
setopt no_list_types

setopt correct
setopt auto_menu

setopt auto_param_keys
setopt auto_param_slash

# resume process if it has suspended as same name
setopt auto_resume


# History
#--------

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt append_history
setopt extended_history
setopt share_history

setopt hist_ignore_dups
#setopt hist_ignore_all_dups
setopt hist_reduce_blanks
#setopt hist_ignore_space
setopt hist_verify


# Completion
#-----------

LISTMAX=0

setopt print_eight_bit
setopt magic_equal_subst
setopt mark_dirs

# enable to cursor selection in completion list selection
zstyle ':completion:*default' menu select=1

# expands '=command' to its path name
setopt equals

# treat '#', '~', '^' as Regexp in filename
setopt extended_glob

# sort numerical order in file name expansion
setopt numeric_glob_sort


# Visuals
#--------

# enable to show 'CR' when it not exist on end of line
unsetopt promptcr

# enable to use colorlize
setopt prompt_subst

# Directory: Cyan
export LS_COLORS='di=01;36'

# enable colorlize file list completion like 'ls'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


# Others
#-------

# without BEEP
setopt no_beep
setopt nolistbeep

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# run 'ls' when exec 'cd'
function chpwd() { ls }

# unable Ctrl+s, Ctrl+q
setopt no_flow_control

# set limitation for core dump size
limit coredumpsize 102400

# replace 'jobs' to 'jobs -l' with internal command
setopt long_list_jobs

# for Subversion
#---------------
export SVN_EDITOR=/usr/bin/vim


#------------------------------
# site customize
#------------------------------

[ -f ${HOME}/.zshrc.local ] && source ${HOME}/.zshrc.local

#__END__
