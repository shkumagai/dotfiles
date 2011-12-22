#!/bin/bash

# setup.sh -- setting up dotfiles to home directory.
#
# :author: Shoji KUMAGAI
# :since: Fri Dec 23 01:56:01 JST 2011

# usage
# -----
# Just do as below:
#
# $ ./setup.sh
#
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


make_symlink()
{
  #echo "args: [$*]"
  file=$1
  suffix=$2

  [[ "$file" = "" ]] && exit 0

  if [[ "$suffix" != "" ]]; then
    ln -Fis "$PWD/$file" "$HOME/.${file%.?*}$suffix"
  else
    ln -Fis "$PWD/$file" "$HOME/.${file}"
  fi
}

make_symlink_local()
{
  make_symlink $1 '.local'
}

for f in `find . -depth 1 -type f`
do
  name="${f##?*/}" # triming
  arch=$(uname -s | tr '[:upper:]' '[:lower:]')

  if [[ "${f##?*rc}" = "" ]]; then
    make_symlink $name
    [[ -f "$name.$arch" ]] && make_symlink_local $name.$arch
  fi
  if [[ "${f##?*config}" = "" ]]; then
    make_symlink $name
  fi
  if [[ "${f##?*ignore}" = "" ]]; then
    make_symlink $name
  fi
done

# END
