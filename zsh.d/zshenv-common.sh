#!/bin/zsh
# .zshenv --- zshenv common environment -*- encoding: utf-8-unix -*-
# shellcheck disable=SC1071

function filter_args () {
  # shellcheck disable=SC2034
  args=$*
  rest=()
  for p in ${=args}; do re="^.*${p}.*$"; [[ ! "${PATH}" =~ ${re} ]] && rest+=("${p}"); done
  echo "${rest[@]}"
}

function append_path () {
  # shellcheck disable=SC2296
  paths=("$(filter_args "$@")"); [[ ${#paths} -gt 0 ]] && export PATH=$PATH:${(j|:|)paths}
}

function prepend_path () {
  # shellcheck disable=SC2296
  paths=("$(filter_args "$@")"); [[ ${#paths} -gt 0 ]] && export PATH=${(j|:|)paths}:$PATH
}

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh
