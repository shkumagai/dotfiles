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
function tty_make_bold() { tty_escape "1;${1}"; }
tty_reset="$(tty_escape 0)"
function print_()   { printf "$(tty_escape "${2}")%s${tty_reset}" "${1}"; }
function print_bold_()  { printf "$(tty_make_bold "${2}")%s${tty_reset}" "${1}"; }
function print_l_()  { printf "$(tty_escape "${2}")%s${tty_reset}\n" "${1}"; }
function print_bold_l_() { printf "$(tty_make_bold "${2}")%s${tty_reset}\n" "${1}"; }

function print_l_c() { pl_ "${1}" 36; }
function print_bold_l_c() { pbl_ "${1}" 36; }

# 構成ファイル
CONFIG_VISASQ_DIR="${HOME}/.config/visasq"
CONFIG_FILE_PATH="${CONFIG_VISASQ_DIR}/config.json"
COMMON_FILE_PATH="${CONFIG_VISASQ_DIR}/common.json"

WORKSPACE_ROOT=$(jq -r '.workspace_path' "${COMMON_FILE_PATH}")


function dump_pull_requests() {
  REPOS=$(gh repo list visasq --limit 200 --json name --jq '.[]|.name' | sort)
  mkdir -p pullrequests
  for repo in ${REPOS}; do
    gh pr list \
        --author "@me" \
        --state "all" \
        --limit 200 \
        --repo visasq/"${repo}" \
        --json number,title,state,createdAt,closedAt,additions,deletions \
        --jq "[.[] | .repo = \"${repo}\"]" \
    > "pullrequests/${repo}.json" &
    sleep 0.2
  done
  wait
}

function print_stats() {
  print_bold_l_c "===== total ================================================"
  jq -s add pullrequests/*.json | jq -r '. | length'

  print_bold_l_c "===== per state ============================================"
  printf "%-6s %-6s\n" "state" "count"
  printf "====== ======\n"
  jq -s add pullrequests/*.json | jq -r 'group_by(.state) | map({"state": .[0].state, "count": [.[]]|length}) | .[] | [.state,.count] | @tsv' \
    | sort -rd \
    | awk -F"\t" '{ printf "%-6s %6s\n", $1, $2; }'

  print_bold_l_c "===== per repository ======================================="
  printf "%-25s %6s %6s %9s %9s\n" "repository name" "merged" "closed" "additions" "deletions"
  printf "========================= ====== ====== ========= =========\n"
  jq -s add pullrequests/*.json \
    | jq -r 'group_by(.repo) | map({ "repo": .[0].repo, "total":  [.[]]|length, "open": [.[]|select(.state=="OPEN")]|length, "merged": [.[]|select(.state=="MERGED")]|length, "closed": [.[]|select(.state=="CLOSED")]|length, "additions": [.[].additions]|add, "deletions": [.[].deletions]|add }) | .[] | [.repo,.merged,.closed,.additions,.deletions] | @tsv' \
    | awk -F"\t" '{ printf "%-25s %6d %6d \x1b[32m%9d\x1b[0m \x1b[31m%9d\x1b[0m\n", $1, $2, $3, $4, $5; }'

  print_bold_l_c "===== per year ============================================="
  printf "%-5s %6s %6s %9s %9s\n" "year" "merged" "closed" "additions" "deletions"
  printf "===== ====== ====== ========= =========\n"
  jq -s add pullrequests/*.json \
    | jq -r '[.[]|select(.state!="OPEN")]|map({"year":.closedAt|fromdate|strftime("%Y"),"state":.state,"repo":.repo,"additions":.additions,"deletions":.deletions})|group_by(.year)|map({ "year":.[0].year, "merged":[.[]|select(.state=="MERGED")]|length, "closed":[.[]|select(.state=="CLOSED")]|length, "additions": [.[].additions]|add, "deletions": [.[].deletions]|add }) | .[] | [.year,.merged,.closed,.additions,.deletions] | @tsv' \
    | awk -F"\t" '{ printf "%-5s %6d %6d \x1b[32m%9d\x1b[0m \x1b[31m%9d\x1b[0m\n", $1, $2, $3, $4, $5; }'
}

function main() {
  [[ -d pullrequests ]] || dump_pull_requests
  print_stats
}

main "$@"
