#!/bin/bash

set -euo pipefail

# shellcheck source=./utils
source "$(dirname "$0")/utils"

load-passwds

# The passphrase is passed via an environment variable (not interpolated into
# the Tcl script) and removed from the environment before spawning ssh-add.
# shellcheck disable=SC2154
AUTO_AGENT_KEY="${1}" AUTO_AGENT_PASSPHRASE="${passphrase}" \
expect -c '
set passphrase $env(AUTO_AGENT_PASSPHRASE)
unset env(AUTO_AGENT_PASSPHRASE)
set timeout 10
spawn ssh-add $env(AUTO_AGENT_KEY)
expect "Enter passphrase for"
send -- "$passphrase\n"
expect "Identity added:"
interact
'
