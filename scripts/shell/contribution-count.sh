#!/bin/bash
# -*- coding: utf-8 -*-
# shellcheck disable=SC2034
set -eEu

# string format functions

if [[ -t 1 ]]; then
  function tty_escape() { printf "\x1b[%sm" "${1}"; }
else
  function tty_escape() { :; }
fi
function tty_mkbold() { tty_escape "1;${1}"; }
tty_reset="$(tty_escape 0)"
function p_()   { printf "$(tty_escape "${2}")%s${tty_reset}" "${1}"; }
function pb_()  { printf "$(tty_mkbold "${2}")%s${tty_reset}" "${1}"; }
function pl_()  { printf "$(tty_escape "${2}")%s${tty_reset}\n" "${1}"; }
function pbl_() { printf "$(tty_mkbold "${2}")%s${tty_reset}\n" "${1}"; }

function pl_g() { pl_ "${1}" 32; }
function pbl_g() { pbl_ "${1}" 32; }

# 構成ファイル
CONFIG_VISASQ_DIR="${HOME}/.config/visasq"
CONFIG_FILE_PATH="${CONFIG_VISASQ_DIR}/config.json"
COMMON_FILE_PATH="${CONFIG_VISASQ_DIR}/common.json"

WORKSPACE_ROOT=$(jq -r '.workspace_path' "${COMMON_FILE_PATH}")


function dump_pull_requests() {
  REPOS=$(cd "${WORKSPACE_ROOT}"; find app infra etc -type f -name "config" \
      | awk -F/ '{ print $2; }' \
      | grep -v release \
      | tr "\n" " ")
  mkdir -p pullrequests
  for repo in ${REPOS}; do
    printf "<%s>\n" "${repo}"
    gh pr list \
        --author "@me" \
        --state "all" \
        --limit 200 \
        --repo visasq/"${repo}" \
        --json number,title,state,createdAt,closedAt \
        --jq "[.[] | .repo = \"${repo}\"]" \
    > "pullrequests/${repo}.json"
    sleep 0.5
  done
}

function print_stats() {
  pl_g "===== total ================================================"
  jq -s add pullrequests/*.json | jq -r '. | length'

  pl_g "===== per state ============================================"
  jq -s add pullrequests/*.json | jq -r 'group_by(.state) | map({"state": .[0].state, "count": [.[]]|length}) | .[] | [.state,.count] | @tsv' | sort -rd | column -t

  pl_g "===== per repository ======================================="
  jq -s add pullrequests/*.json \
    | jq -r 'group_by(.repo) | map({ "repo": .[0].repo, "total":  [.[]]|length, "open": [.[]|select(.state=="OPEN")]|length, "merged": [.[]|select(.state=="MERGED")]|length, "closed": [.[]|select(.state=="CLOSED")]|length }) | .[] | [.repo,.merged,.closed] | @tsv' \
    | column -t

  pl_g "===== per year ============================================="
  jq -s add pullrequests/*.json \
    | jq -r '[.[]|select(.state!="OPEN")]|map({"year":.closedAt|fromdate|strftime("%Y"),"state":.state,"repo":.repo})|group_by(.year)|map({"year":.[0].year, "merged":[.[]|select(.state=="MERGED")]|length, "closed":[.[]|select(.state=="CLOSED")]|length}) | .[] | [.year,.merged,.closed] | @tsv' \
    | column -t
}

function main() {
  [[ -d pullrequests ]] || dump_pull_requests
  print_stats
}

main "$@"
