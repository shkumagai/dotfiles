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

function p_r() { p_ "${1}" 31; }
function p_g() { p_ "${1}" 32; }
function p_y() { p_ "${1}" 33; }
function p_b() { p_ "${1}" 34; }
function p_m() { p_ "${1}" 35; }
function p_c() { p_ "${1}" 36; }
function p_w() { p_ "${1}" 37; }

function pb_r() { pb_ "${1}" 31; }
function pb_g() { pb_ "${1}" 32; }
function pb_y() { pb_ "${1}" 33; }
function pb_b() { pb_ "${1}" 34; }
function pb_m() { pb_ "${1}" 35; }
function pb_c() { pb_ "${1}" 36; }
function pb_w() { pb_ "${1}" 37; }

function pl_r() { pl_ "${1}" 31; }
function pl_g() { pl_ "${1}" 32; }
function pl_y() { pl_ "${1}" 33; }
function pl_b() { pl_ "${1}" 34; }
function pl_m() { pl_ "${1}" 35; }
function pl_c() { pl_ "${1}" 36; }
function pl_w() { pl_ "${1}" 37; }

function pbl_r() { pbl_ "${1}" 31; }
function pbl_g() { pbl_ "${1}" 32; }
function pbl_y() { pbl_ "${1}" 33; }
function pbl_b() { pbl_ "${1}" 34; }
function pbl_m() { pbl_ "${1}" 35; }
function pbl_c() { pbl_ "${1}" 36; }
function pbl_w() { pbl_ "${1}" 37; }

tty_red="$(tty_escape 31)"
tty_green="$(tty_escape 32)"
tty_yellow="$(tty_escape 33)"
tty_blue="$(tty_escape 34)"
tty_magenta="$(tty_escape 35)"
tty_cyan="$(tty_escape 36)"
tty_white="$(tty_escape 37)"

tty_red_b="$(tty_mkbold 31)"
tty_green_b="$(tty_mkbold 32)"
tty_yellow_b="$(tty_mkbold 33)"
tty_blue_b="$(tty_mkbold 34)"
tty_magenta_b="$(tty_mkbold 35)"
tty_cyan_b="$(tty_mkbold 36)"
tty_white_b="$(tty_mkbold 37)"

function color_test() {
  local lorem_ipsum
  lorem_ipsum="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

  echo "=== Normal, without new-line =========================================="
  p_r "${lorem_ipsum}"
  p_g "${lorem_ipsum}"
  p_y "${lorem_ipsum}"
  p_b "${lorem_ipsum}"
  p_m "${lorem_ipsum}"
  p_c "${lorem_ipsum}"
  p_w "${lorem_ipsum}"
  echo ""
  echo "=== Normal, with new-line ============================================="
  pl_r "${lorem_ipsum}"
  pl_g "${lorem_ipsum}"
  pl_y "${lorem_ipsum}"
  pl_b "${lorem_ipsum}"
  pl_m "${lorem_ipsum}"
  pl_c "${lorem_ipsum}"
  pl_w "${lorem_ipsum}"
  echo "=== Bold, without new-line ============================================"
  pb_r "${lorem_ipsum}"
  pb_g "${lorem_ipsum}"
  pb_y "${lorem_ipsum}"
  pb_b "${lorem_ipsum}"
  pb_m "${lorem_ipsum}"
  pb_c "${lorem_ipsum}"
  pb_w "${lorem_ipsum}"
  echo ""
  echo "=== Bold, with new-line ==============================================="
  pbl_r "${lorem_ipsum}"
  pbl_g "${lorem_ipsum}"
  pbl_y "${lorem_ipsum}"
  pbl_b "${lorem_ipsum}"
  pbl_m "${lorem_ipsum}"
  pbl_c "${lorem_ipsum}"
  pbl_w "${lorem_ipsum}"
}
