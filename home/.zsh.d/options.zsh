# -*- mode: zsh; encoding: utf-8 -*-

# Automations

# ディレクトリ名でcd
setopt auto_cd

# 補完候補を一覧表示する
setopt auto_list

# 補完候補一覧で自動的にメニュー表示する
setopt auto_menu

# カッコやクォートの中で補完する際に、補完候補のキーを自動的に挿入する
setopt auto_param_keys

# カッコやクォートの中で補完する際に、補完候補のスラッシュを自動的に挿入する
setopt auto_param_slash

# ディレクトリ移動時にpushdする
setopt auto_pushd

# 既に同じジョブが存在する場合に、ジョブを再開する
setopt auto_resume

# 語の途中でもカーソル位置で補完
setopt complete_in_word

# コマンドの補完時に誤字を自動修正する
setopt correct

# 補完候補一覧で、複数列表示する際に、列の幅を詰めて表示する
setopt list_packed

# 補完候補一覧でファイルの種別マークを表示しない
setopt no_list_types

# 色を付ける
setopt prompt_subst

# 同じディレクトリをpushdしない
setopt pushd_ignore_dups

# 入力が長い場合に、右プロンプトを一時的に非表示にする
setopt transient_rprompt


# Completions

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


# Histories

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


# Visuals

# 改行コードをプロンプトに表示しない
unsetopt promptcr


# Others

# ビープ音を鳴らさない
setopt no_beep

# 曖昧な補完時にビープ音を鳴らさない
setopt no_list_beep

# シェルのフロー制御 (Ctrl+S/Ctrl+Q) を無効にする
setopt no_flow_control

# ジョブ一覧を長い形式で表示する
setopt long_list_jobs

# 語の区切り文字を調整する
# ‐ /\ を語の区切り文字として扱う
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ディレクトリ移動時に自動的にlsを実行する
function chpwd() { ls }


# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
