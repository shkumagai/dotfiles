#!/bin/bash

set -euo pipefail

TEMP_PASSWD=/tmp/_passwd

# shellcheck source=/tmp/_passwd disable=SC1091
source "${TEMP_PASSWD}"

# shellcheck disable=SC2154
expect -c "
set timeout 10
spawn ssh-add ${1}
expect \"Enter passphrase for\"
send \"${passphrase}\n\"
expect \"Identity added:\"
interact
"
