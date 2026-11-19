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

function print_l_c() { print_l_ "${1}" 36; }
function print_bold_l_c() { print_bold_l_ "${1}" 36; }

# 自分の PR のダンプは pr-contribution skill（scripts/dump_prs.py）で行い、ここでは集計表を出すだけにする
# データは <data_dir>/<owner>/<repo>.json（PR の配列）。直下の _meta.json は集計に入れない
PR_CONTRIBUTION_DATA_DIR="${PR_CONTRIBUTION_DATA_DIR:-${HOME}/.local/share/pr-contribution/data}"

function load_data_files() {
  shopt -s nullglob
  DATA_FILES=("${PR_CONTRIBUTION_DATA_DIR}"/*/*.json)
  shopt -u nullglob
  if [[ ${#DATA_FILES[@]} -eq 0 ]]; then
    {
      echo "no PR data in ${PR_CONTRIBUTION_DATA_DIR}"
      echo "dump your PRs with the pr-contribution skill, or run:"
      echo "  python3 -I scripts/dump_prs.py --data-dir ${PR_CONTRIBUTION_DATA_DIR} --owner <owner> [--owner ...]"
      echo "(set PR_CONTRIBUTION_DATA_DIR to read another directory)"
    } >&2
    exit 1
  fi
}

function all_pull_requests() {
  jq -s add "${DATA_FILES[@]}"
}

function print_stats() {
  print_stats_total
  echo
  print_stats_by_state
  echo
  print_stats_by_repository
  echo
  print_stats_by_year
}

function print_stats_total() {
  print_bold_l_c "===== total ==================================================="
  all_pull_requests | jq -r '. | length'
}

function print_stats_by_state() {
  print_bold_l_c "===== per state ==============================================="
  printf "%-6s %-6s\n" "state" "count"
  printf "====== ======\n"
  all_pull_requests | jq -r 'group_by(.state) | map({"state": .[0].state, "count": [.[]]|length}) | .[] | [.state,.count] | @tsv' \
    | sort -rd \
    | awk -F"\t" '{ printf "%-6s %6s\n", $1, $2; }'
}

function print_stats_by_repository() {
  print_bold_l_c "===== per repository =========================================="
  printf "%-29s %6s %6s %9s %9s\n" "repository name" "merged" "closed" "additions" "deletions"
  printf "============================= ====== ====== ========= =========\n"
  # owner が 2 つ以上あると同じリポジトリ名がぶつかるので、そのときは owner/repo で表示する
  all_pull_requests \
    | jq 'if (map(.owner) | unique | length) > 1 then map(.repo = .owner + "/" + .repo) else . end' \
    | jq -r 'group_by(.repo) | map({ "repo": .[0].repo, "total":  [.[]]|length, "open": [.[]|select(.state=="OPEN")]|length, "merged": [.[]|select(.state=="MERGED")]|length, "closed": [.[]|select(.state=="CLOSED")]|length, "additions": [.[].additions]|add, "deletions": [.[].deletions]|add }) | .[] | [.repo,.merged,.closed,.additions,.deletions] | @tsv' \
    | awk -F"\t" '{ printf "%-29s %6d %6d \x1b[32m%9d\x1b[0m \x1b[31m%9d\x1b[0m\n", $1, $2, $3, $4, $5; }'
}

function print_stats_by_year() {
  print_bold_l_c "===== per year ================================================"
  printf "%-29s %6s %6s %9s %9s\n" "year" "merged" "closed" "additions" "deletions"
  printf "============================= ====== ====== ========= =========\n"
  all_pull_requests \
    | jq -r '[.[]|select(.state!="OPEN")]|map({"year":.closedAt|fromdate|strftime("%Y"),"state":.state,"repo":.repo,"additions":.additions,"deletions":.deletions})|group_by(.year)|map({ "year":.[0].year, "merged":[.[]|select(.state=="MERGED")]|length, "closed":[.[]|select(.state=="CLOSED")]|length, "additions": [.[].additions]|add, "deletions": [.[].deletions]|add }) | .[] | [.year,.merged,.closed,.additions,.deletions] | @tsv' \
    | awk -F"\t" '{ printf "%-29s %6d %6d \x1b[32m%9d\x1b[0m \x1b[31m%9d\x1b[0m\n", $1, $2, $3, $4, $5; }'
}

function main() {
  load_data_files
  print_stats
}

main "$@"
