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

function print_r() { print_ "${1}" 31; }
function print_g() { print_ "${1}" 32; }
function print_y() { print_ "${1}" 33; }
function print_b() { print_ "${1}" 34; }
function print_m() { print_ "${1}" 35; }
function print_c() { print_ "${1}" 36; }
function print_w() { print_ "${1}" 37; }

function print_bold_r() { print_bold_ "${1}" 31; }
function print_bold_g() { print_bold_ "${1}" 32; }
function print_bold_y() { print_bold_ "${1}" 33; }
function print_bold_b() { print_bold_ "${1}" 34; }
function print_bold_m() { print_bold_ "${1}" 35; }
function print_bold_c() { print_bold_ "${1}" 36; }
function print_bold_w() { print_bold_ "${1}" 37; }

function print_l_r() { print_l_ "${1}" 31; }
function print_l_g() { print_l_ "${1}" 32; }
function print_l_y() { print_l_ "${1}" 33; }
function print_l_b() { print_l_ "${1}" 34; }
function print_l_m() { print_l_ "${1}" 35; }
function print_l_c() { print_l_ "${1}" 36; }
function print_l_w() { print_l_ "${1}" 37; }

function print_bold_l_r() { print_bold_l_ "${1}" 31; }
function print_bold_l_g() { print_bold_l_ "${1}" 32; }
function print_bold_l_y() { print_bold_l_ "${1}" 33; }
function print_bold_l_b() { print_bold_l_ "${1}" 34; }
function print_bold_l_m() { print_bold_l_ "${1}" 35; }
function print_bold_l_c() { print_bold_l_ "${1}" 36; }
function print_bold_l_w() { print_bold_l_ "${1}" 37; }

tty_red="$(tty_escape 31)"
tty_green="$(tty_escape 32)"
tty_yellow="$(tty_escape 33)"
tty_blue="$(tty_escape 34)"
tty_magenta="$(tty_escape 35)"
tty_cyan="$(tty_escape 36)"
tty_white="$(tty_escape 37)"

tty_red_b="$(tty_make_bold 31)"
tty_green_b="$(tty_make_bold 32)"
tty_yellow_b="$(tty_make_bold 33)"
tty_blue_b="$(tty_make_bold 34)"
tty_magenta_b="$(tty_make_bold 35)"
tty_cyan_b="$(tty_make_bold 36)"
tty_white_b="$(tty_make_bold 37)"

function color_test() {
  local lorem_ipsum
  lorem_ipsum="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

  echo "=== Normal, without new-line =========================================="
  print_r "${lorem_ipsum}"
  print_g "${lorem_ipsum}"
  print_y "${lorem_ipsum}"
  print_b "${lorem_ipsum}"
  print_m "${lorem_ipsum}"
  print_c "${lorem_ipsum}"
  print_w "${lorem_ipsum}"
  echo ""
  echo "=== Normal, with new-line ============================================="
  print_l_r "${lorem_ipsum}"
  print_l_g "${lorem_ipsum}"
  print_l_y "${lorem_ipsum}"
  print_l_b "${lorem_ipsum}"
  print_l_m "${lorem_ipsum}"
  print_l_c "${lorem_ipsum}"
  print_l_w "${lorem_ipsum}"
  echo "=== Bold, without new-line ============================================"
  print_bold_r "${lorem_ipsum}"
  print_bold_g "${lorem_ipsum}"
  print_bold_y "${lorem_ipsum}"
  print_bold_b "${lorem_ipsum}"
  print_bold_m "${lorem_ipsum}"
  print_bold_c "${lorem_ipsum}"
  print_bold_w "${lorem_ipsum}"
  echo ""
  echo "=== Bold, with new-line ==============================================="
  print_bold_l_r "${lorem_ipsum}"
  print_bold_l_g "${lorem_ipsum}"
  print_bold_l_y "${lorem_ipsum}"
  print_bold_l_b "${lorem_ipsum}"
  print_bold_l_m "${lorem_ipsum}"
  print_bold_l_c "${lorem_ipsum}"
  print_bold_l_w "${lorem_ipsum}"
}
