#!/bin/bash

# setup.sh -- setting up dotfiles to home directory.
#
# :author: Shoji KUMAGAI
# :since: Wed May  8 00:13:15 2013

SRC=$PWD
DST=$HOME

files=( gitconfig \
        gitignore \
        vimrc \
        vim \
        zshrc \
        zshenv \
        zsh.d \
        tmux.d \
        tmux.conf \
)
# echo "files: ${files[@]}"

for file in "${files[@]}"; do
  # echo "ln -sf $SRC/$file $DST/.$file"
  [[ -h "${DST}/.$file" ]] && rm "${DST}/.$file"
  ln -s "${SRC}/$file" "${DST}/.$file"
  ls -l "${DST}/.$file"
done

dirs=( mise )

for dir in "${dirs[@]}"; do
  ln -sF "${SRC}/config/${dir}" "${HOME}/.config/${dir}"
  ls -l "${HOME}/.config/${dir}"
done

# install NeoBundle for vim
if [ ! -d ~/.vim/bundle/neobundle.vim ]; then
  echo "neobundle.vim are not exist. it'll clone there..."
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
fi

ls -l ~/.zsh.d/zfunc

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
