#!/bin/bash

TEMP_PASSWD=/tmp/_passwd

# shellcheck source=/tmp/_passwd
source "${TEMP_PASSWD}"

expect -c "
set timeout 10
spawn ssh-add ${1}
expect \"Enter passphrase for\"
send \"${passphrase}\n\"
expect \"Identity added:\"
interact
"
