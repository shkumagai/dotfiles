#!/bin/bash

# setup.sh -- setting up dotfiles to home directory.
#
# :author: Shoji KUMAGAI
# :since: Fri Dec 23 01:56:01 JST 2011

# symbolic link naming rule
# -------------------------
# xxx         --> $HOME/.xxx
# xxx.darwin  --> $HOME/.xxx.local
#
# The file that has suffix like `darwin` used for configuration in certain
# sysmem. In the case above, `xxx.darwin` is used to configuration of
# application like Shell (ex. bash, zsh), VCS (ex. mercurial, git), and so
# on. Of course, dotfiles should be designed in which it has interfaces to
# include the system inherent configuration.

# Here is a sample code for zshrc:
#
#  [[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# escape sequence
#
readonly red='0;31'
readonly green='0;32'
readonly brown='0;33'
readonly blue='0;34'
readonly gray='0;37'
readonly org='0;0'

DEBUG=0
FORCE_UPDATE=0
SRC=$PWD
DEST=$HOME

USAGE_MSG='usage:
    setup.sh [option]

option:
    -d               run as debug mode
    -f               force update symbolic link
    -h               print help message
    -v               print version
'
usage()
{
  echo "$USAGE_MSG" 1>&2
}

VERSION='0.2.0'
version()
{
  echo "version: ${1}"
}

colored_echo()
{
  color="${2:-$org}"
  echo -e "\033[${2}m${1}\033[${org}m"
}

debug()
{
  [ $DEBUG -ne 0 ] && colored_echo "DEBUG: ${1}" $gray
}

lc() {
  echo -n $( echo ${1} | tr "[:upper:]" "[:lower:]" )
}

symlink()
{
  debug "ln $*"
  ln $*
}

make_symlink()
{
  debug "  args: [$*]"
  file=$1
  suffix=$2
  [[ "$file" = "" ]] && exit 0

  from="$SRC/$file"

  if [[ "$suffix" != "" ]]; then
    to="$DEST/.${file%.?*}$suffix"
  else
    to="$DEST/.${file}"
  fi

  if [[ $FORCE_UPDATE -eq 1 ]]; then
    LN_OPTS="-fs"
  else
    LN_OPTS="-is"
  fi
  symlink $LN_OPTS $from $to
}

make_symlink_local()
{
  make_symlink $1 '.local'
}

create_gitconfig_local()
{
  if [ ! -f "gitconfig.local" -o $FORCE_UPDATE -eq 1 ]; then
    echo -n "Your email address?: "
    read mail_addr
    debug "received: [${mail_addr}]"

    echo -n "Github oauth-token (if you know)?: "
    read oauth_token
    debug "received: [${oauth_token}]"

    cat <<_EOT_ > gitconfig.local
[user]
    name = Shoji KUMAGAI
    email = ${mail_addr}

[github]
    user = shkumagai
    oauth-token = ${oauth_token}
_EOT_

  fi
}

run()
{
  if [ $# -eq 0 ]; then
    files=$(find . -maxdepth 1 ! -name ".*")
  else
    files="$@"
  fi
  debug "files #=> $files"

  arch=$(lc `uname -s`)
  debug "arch #=> $arch"

  # create_gitconfig_local

  for f in $files
  do
    name="${f##?*/}" # triming
    debug "name #=> $name"

    if [[ "${f##?*env}" = "" ]]; then
      make_symlink $name
      [ -f "$SRC/zsh.d/$name.$arch" ] && symlink "-fs" "$SRC/zsh.d/$name.$arch" "$SRC/zsh.d/$name"
    fi
    if [[ "${f##?*rc}" = "" ]]; then
      make_symlink $name
      # [ -f "$name.$arch" ] && make_symlink_local $name.$arch
      [ -f "$SRC/zsh.d/$name.$arch" ] && symlink "-fs" "$SRC/zsh.d/$name.$arch" "$SRC/zsh.d/$name"
    fi
    if [[ "${f##?*config}" = "" ]]; then
      make_symlink $name
      [ -f "$name.local" ] && make_symlink_local $name.local
    fi
    if [[ "${f##?*ignore}" = "" ]]; then
      make_symlink $name
    fi
    if [[ "${f##?*.d}" = "" ]]; then
      make_symlink ${name}/
    fi
  done
}

### Main
while getopts dfhv option; do
  case "$option" in
    d)
      DEBUG=1
      echo "Enable debug output."
      ;;
    f)
      FORCE_UPDATE=1
      echo "Enable symbolic links force update."
      ;;
    h|\?)
      usage; exit 0
      ;;
    v)
      version $VERSION; exit 0
      ;;
  esac
done
shift $(($OPTIND - 1))

run "$@"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
