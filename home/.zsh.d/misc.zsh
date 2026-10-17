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
# chpwd() を直接定義すると他のフックを上書きするので add-zsh-hook で登録する
autoload -Uz add-zsh-hook
_ls_on_chpwd() { ls }
add-zsh-hook chpwd _ls_on_chpwd
