# -*- encoding: utf-8 -*-
# shellcheck shell=zsh

# Mise
# NOTE: GUIアプリケーションから起動した場合、miseコマンドが
# PATHに含まれないため、miseコマンドの存在を確認してから実行する
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
