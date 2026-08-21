# -*- mode: zsh; encoding: utf-8 -*-

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

# 補完候補のディレクトリ名に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


# Default: --

# 補完候補の一覧表示の区切り文字を設定する
zstyle ':completion:*' list-separator '-->'

# manの補完候補をセクションごとに分けて表示する
zstyle ':completion:*:manuals' separate-sections true


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
