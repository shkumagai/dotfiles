# -*- mode: zsh; encoding: utf-8 -*-

# Histories

# ヒストリファイルパス
HISTFILE="${XDG_STATE_HOME}/zsh/history"
mkdir -p "${HISTFILE:h}"

# ヒストリサイズの上限
HISTSIZE=100000
SAVEHIST=100000

# ヒストリを上書きではなく、追記する
setopt append_history

# ヒストリにコマンドの実行開始時間を記録する
setopt extended_history

# ヒストリに重複するコマンドを記録しない
setopt hist_ignore_dups

# ヒストリの余分な空白を削減する
setopt hist_reduce_blanks

# 履歴を直接実行せず、編集バッファに展開してから実行する
setopt hist_verify

# ヒストリを複数のシェルで共有する
setopt share_history
