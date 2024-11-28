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
  REPOS=$(gh repo list visasq --limit 200 --json name --jq '.[]|.name' | sort)
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
    sleep 1.5
  done
}

function print_stats() {
  pl_g "===== total ================================================"
  jq -s add pullrequests/*.json | jq -r '. | length'

  pl_g "===== per state ============================================"
  printf "%-6s %-6s\n" "state" "count"
  printf "====== ======\n"
  jq -s add pullrequests/*.json | jq -r 'group_by(.state) | map({"state": .[0].state, "count": [.[]]|length}) | .[] | [.state,.count] | @tsv' \
    | sort -rd \
    | awk -F"\t" '{ printf "%-6s %6s\n", $1, $2; }'

  pl_g "===== per repository ======================================="
  printf "%-25s %6s %6s\n" "repository name" "merged" "closed"
  printf "========================= ====== ======\n"
  jq -s add pullrequests/*.json \
    | jq -r 'group_by(.repo) | map({ "repo": .[0].repo, "total":  [.[]]|length, "open": [.[]|select(.state=="OPEN")]|length, "merged": [.[]|select(.state=="MERGED")]|length, "closed": [.[]|select(.state=="CLOSED")]|length }) | .[] | [.repo,.merged,.closed] | @tsv' \
    | awk -F"\t" '{ printf "%-25s %6s %6s\n", $1, $2, $3; }'

  pl_g "===== per year ============================================="
  printf "%-5s %6s %6s\n" "year" "merged" "closed"
  printf "===== ====== ======\n"
  jq -s add pullrequests/*.json \
    | jq -r '[.[]|select(.state!="OPEN")]|map({"year":.closedAt|fromdate|strftime("%Y"),"state":.state,"repo":.repo})|group_by(.year)|map({"year":.[0].year, "merged":[.[]|select(.state=="MERGED")]|length, "closed":[.[]|select(.state=="CLOSED")]|length}) | .[] | [.year,.merged,.closed] | @tsv' \
    | awk -F"\t" '{ printf "%-5s %6s %6s\n", $1, $2, $3; }'
}

function main() {
  [[ -d pullrequests ]] || dump_pull_requests
  print_stats
}

main "$@"
