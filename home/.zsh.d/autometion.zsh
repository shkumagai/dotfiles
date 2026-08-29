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

# Correction オプション
CORRECT_IGNORE='_*'
CORRECT_IGNORE_FILE='.*'

# 補完候補一覧で、複数列表示する際に、列の幅を詰めて表示する
setopt list_packed

# 補完候補一覧でファイルの種別マークを表示しない
setopt no_list_types

# 同じディレクトリをpushdしない
setopt pushd_ignore_dups
