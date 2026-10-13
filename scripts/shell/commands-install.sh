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
  # ID= line only (not ID_LIKE=), without surrounding quotes
  # shellcheck source=/dev/null
  (. /etc/os-release && printf "%s" "${ID}")
}

# NOTE: functions below use `case` / `if` instead of `[ ... ] && cmd`,
# whose non-zero status at the end of a function aborts the script under `set -e`.

if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

function _apt() {
  ${SUDO} apt-get update -y
  ${SUDO} apt-get install -y "$@"
}

function _pacman() {
  ${SUDO} pacman -Sy --noconfirm "$@"
}

function _jq() {
  case "$(distro)" in
    debian) _apt jq ;;
    arch) _pacman jq ;;
  esac
}

function _yq() {
  case "$(distro)" in
    debian)
      ${SUDO} curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
      ${SUDO} chmod +x /usr/local/bin/yq
      ;;
    arch) _pacman go-yq ;;
  esac
}

function _pkgconfig() {
  case "$(distro)" in
    debian) _apt pkg-config ;;
    arch) _pacman pkg-config ;;
  esac
}

function _peco() {
  case "$(distro)" in
    debian) _apt peco ;;
    arch) _pacman peco ;;
  esac
}

function _pipx() {
  case "$(distro)" in
    debian) _apt pipx ;;
    arch) _pacman python-pipx ;;
  esac
}

function _pyenv() {
  curl https://pyenv.run | bash
  case "$(distro)" in
    debian)
      _apt build-essential libssl-dev \
        zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
      ;;
    arch) _pacman --needed base-devel openssl zlib xz tk ;;
  esac
}

function _gcloud() {
  cd "${HOME}"
  ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "arm") && export ARCH
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${ARCH}.tar.gz && \
  tar -zxf google-cloud-cli-linux-${ARCH}.tar.gz && ./google-cloud-sdk/install.sh && \
  rm "google-cloud-cli-linux-${ARCH}.tar.gz"
}

function prerequisites() {
  local installer pkg
  case "$(distro)" in
    debian) installer=_apt ;;
    arch) installer=_pacman ;;
    *) return 0 ;;
  esac
  for pkg in curl git; do
    if ! command -v "${pkg}" >/dev/null 2>&1; then
      "${installer}" "${pkg}"
    fi
  done
}

function main() {
  cmd=${1:-}
  if [ "${cmd}" = "" ]; then
    print_bold_ln_r "Command name are not specified."
    exit 1
  fi
  if ! declare -F "_${cmd}" >/dev/null; then
    abort "Unknown command: ${cmd}"
  fi
  prerequisites
  ("_${cmd}")
  echo "..."
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    abort "Installing ${cmd} on this OS is not supported by this script."
  fi
}

main "$@"
