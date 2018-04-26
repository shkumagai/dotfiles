#!/bin/bash

TEMP_PASSWD=/tmp/_passwd
MARK="\$"

source ${TEMP_PASSWD}

while getopts bz option; do
    case "$option" in
        b) MARK="\$" ;;
        z) MARK="%" ;;
    esac
done
shift $(($OPTIND - 1))

expect -c "
set timeout 10
spawn ssh-add ${1}
expect \"Enter passphrase for\"
send \"${passphrase}\n\"
expect \"Identity added:\"
interact
"
