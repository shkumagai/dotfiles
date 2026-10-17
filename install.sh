#!/usr/bin/env bash
# shellcheck shell=bash

set -eu -o pipefail

DOTFILES="${HOME}/.dotfiles"

# Unapply the deployed dotfiles first, then re-run the whole bootstrap (reset on re-run)
make_targets=(clean install)

for arg in "$@"; do
  case "$arg" in
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0" >&2
      exit 1
      ;;
  esac
done

# Clone dotfiles repository if it does not exist
if [ ! -d "${DOTFILES}" ]; then
  git clone https://github.com/shkumagai/dotfiles.git "${DOTFILES}"
fi

make -C "${DOTFILES}" "${make_targets[@]}"
