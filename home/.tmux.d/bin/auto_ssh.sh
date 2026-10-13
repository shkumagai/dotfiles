#!/bin/bash

set -euo pipefail

# shellcheck source=./utils
source "$(dirname "$0")/utils"
MARK="\$"

load-passwds

while getopts bz option; do
  case "$option" in
    b) MARK="\$" ;;
    z) MARK="%" ;;
    *)
  esac
done
shift $(("${OPTIND}" - 1))

# Secrets are passed via environment variables (not interpolated into the
# Tcl script) and removed from the environment before spawning ssh.
# shellcheck disable=SC2154
AUTO_SSH_HOST="${1}" AUTO_SSH_COMMAND="${2}" AUTO_SSH_MARK="${MARK}" \
AUTO_SSH_PASSWD="${passwd}" AUTO_SSH_PASSPHRASE="${passphrase}" \
expect -c '
set passwd $env(AUTO_SSH_PASSWD)
set passphrase $env(AUTO_SSH_PASSPHRASE)
unset env(AUTO_SSH_PASSWD) env(AUTO_SSH_PASSPHRASE)
set timeout 10
spawn ssh $env(AUTO_SSH_HOST)
expect "Enter passphrase for key"
send -- "$passphrase\n"
expect -- $env(AUTO_SSH_MARK)
send -- "sudo su -\n"
expect "Password: "
send -- "$passwd\n"
expect "#"
send -- "$env(AUTO_SSH_COMMAND)\n"
interact
'
