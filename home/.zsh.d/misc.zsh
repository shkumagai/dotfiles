# -*- mode: zsh; encoding: utf-8 -*-

# Keybinds

# キーバインドを emacs に
bindkey -e


# Others

# ビープ音を鳴らさない
setopt no_beep

# 曖昧な補完時にビープ音を鳴らさない
setopt no_list_beep

# シェルのフロー制御 (Ctrl+S/Ctrl+Q) を無効にする
setopt no_flow_control

# ジョブ一覧を長い形式で表示する
setopt long_list_jobs

# core dump のサイズ上限を設定する
limit coredumpsize 102400

# 語の区切り文字を調整する
# ‐ /\ を語の区切り文字として扱う
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ディレクトリ移動時に自動的にlsを実行する
function chpwd() { ls }
