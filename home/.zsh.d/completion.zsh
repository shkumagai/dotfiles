# -*- mode: zsh; encoding: utf-8 -*-

# Completions

LISTMAX=0

# =command を command のパス名に展開する
setopt equals

# 補完候補のパターンマッチングを拡張する
setopt extended_glob

# 補完候補のパターンマッチングで、数値を数値として扱う
setopt numeric_glob_sort

# 補完候補のパターンマッチングで、=command を command のパス名に展開する
setopt magic_equal_subst

# 補完候補のディレクトリ名にスラッシュを付ける
setopt mark_dirs

# 補完候補の8bit文字を正しく表示する
setopt print_eight_bit


# Completion Styles

# 補完候補を一覧から選択する（補完候補が複数無ければ一覧表示しない）
zstyle ':completion:*:default' menu select=1


# Completion groups

# 補完候補の説明を表示する
zstyle ':completion:*:options' description 'yes'

# 補完候補の説明のフォーマットを設定する
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'

# 補完候補のグループ名を表示しない
zstyle ':completion:*' group-name ''


# Completion misc

# 補完候補の大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補の詳細な説明を表示する
zstyle ':completion:*' verbose yes

# 補完候補の表示方法を設定する
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history

# 補完対象から除外するファイル名パターンを設定する
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'

# sudo の時に補完対象のコマンドのパスを設定する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# キャッシュを有効にする
zstyle ':completion:*:' use-cache on

# 変数の添字を補完する
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters


# Directory

# 補完対象から除外するディレクトリを設定する
zstyle ':completion:*:cd:*' ignore-parents parent pwd


# Default: --

# 補完候補の一覧表示の区切り文字を設定する
zstyle ':completion:*' list-separator '-->'

# manの補完候補をセクションごとに分けて表示する
zstyle ':completion:*:manuals' separate-sections true
