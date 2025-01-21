#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -eEu
set -o pipefail

function abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

# utilities
if [[ -t 1 ]]; then
  function tty_escape() { printf "\x1b[%sm" "${1}"; }
else
  function tty_escape() { :; }
fi
function tty_make_bold() { tty_escape "1;${1}"; }
tty_reset="$(tty_escape 0)"
function print_bold_ln_() { printf "$(tty_make_bold "${2}")%s${tty_reset}\n" "${1}"; }
function print_bold_ln_r() { print_bold_ln_ "${1}" 31; }
function print_bold_ln_g() { print_bold_ln_ "${1}" 32; }
function print_bold_ln_y() { print_bold_ln_ "${1}" 33; }
function distro() {
  printf "%s" "$(cat /etc/os-release | grep -E \^ID | cut -d= -f2)"
}

SUDO=$([ "$(id -u)" ] && echo "" || echo "sudo")

function _apt() {
  ${SUDO} apt-get update -y && ${SUDO} apt-get install -y "${*}"
}

function _pacman() {
  ${SUDO} pacman -Sy --noconfirm "${*}"
}

function _jq() {
  [ "$(distro)" = "debian" ] && _apt jq
  [ "$(distro)" = "arch" ] && _pacman jq
}

function _yq() {
  [ "$(distro)" = "debian" ] && ${SUDO} apt-get update -y && \
    ${SUDO} curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    ${SUDO} chmod +x /usr/local/bin/yq
  [ "$(distro)" = "arch" ] && _pacman go-yq
}

function _pkgconfig() {
  [ "$(distro)" = "debian" ] && _apt pkg-config
  [ "$(distro)" = "arch" ] && _pacman pkg-config
}

function _peco() {
  [ "$(distro)" = "debian" ] && _apt peco
  [ "$(distro)" = "arch" ] && _pacman peco
}

function _pipx() {
  [ "$(distro)" = "debian" ] && _apt pipx
  [ "$(distro)" = "arch" ] && _pacman python-pipx
}

function _pyenv() {
  curl https://pyenv.run | bash
  [ "$(distro)" = "debian" ] && _apt build-essential libssl-dev \
    zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  [ "$(distro)" = "arch" ] && _pacman --needed base-devel openssl zlib xz tk
}

function _gcloud() {
  cd "${HOME}"
  ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "arm") && export ARCH
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${ARCH}.tar.gz && \
  tar -zxf google-cloud-cli-linux-${ARCH}.tar.gz && ./google-cloud-sdk/install.sh && \
  rm "google-cloud-cli-linux-${ARCH}.tar.gz"
}

function prerequisites() {
  if [ "$(distro)" = "debian" ]; then
    [ -z "$(command -v curl)" ] && _apt curl
    [ -z "$(command -v git)" ] && _apt git
  elif [ "$(distro)" = "arch" ]; then
    [ -z "$(command -v curl)" ] && _pacman curl
    [ -z "$(command -v git)" ] && _pacman git
  fi
}

function main() {
  cmd=${1:-}
  [ "${cmd}" = "" ] && print_bold_ln_r "Command name are not specified." && exit 1
  prerequisites
  ("_${cmd}")
  echo "..."
  [ -z "$(command -v "${cmd}")" ] && abort "Installing ${cmd} on this OS is not supported by this script."
}

main "$@"
