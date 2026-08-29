# -*- mode: zsh; encoding: utf-8 -*-

# Visuals

# 改行コードをプロンプトに表示しない
unsetopt promptcr

# 環境変数: LSCOLORS, LS_COLORS
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36'

# enable colorlize file list completion like 'ls'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
