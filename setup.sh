#!/bin/bash

# setup.sh -- setting up dotfiles to home directory.
#
# :author: Shoji KUMAGAI
# :since: Wed May  8 00:13:15 2013

SRC=$PWD
DST=$HOME

files=( gitconfig \
        gitignore \
        gitconfig.local \
        hgrc \
        hgrc.d \
        hgignore \
        perltidyrc \
        vimrc \
        vim \
        zshrc \
        zshenv \
        zsh.d \
        tmux.d \
        tmux.conf \
)
# echo "files: ${files[@]}"

zshfiles=( zshenv \
)
# echo "zshfiles: ${zshfiles[@]}"

for file in ${files[@]}; do
  # echo "ln -sf $SRC/$file $DST/.$file"
  [[ -h $DST/.$file ]] && rm $DST/.$file
  ln -s $SRC/$file $DST/.$file
  ls -l $DST/.$file
done

arch=$( uname -s | tr "[:upper:]" "[:lower:]" )

for zfile in ${zshfiles[@]}; do
  # echo "ln -sf $SRC/zsh.d/$zfile.$arch $SRC/zsh.d/.$zfile"
  ln -sf $SRC/zsh.d/$zfile.$arch $SRC/zsh.d/$zfile
  ls -l $SRC/zsh.d/$zfile
done

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
