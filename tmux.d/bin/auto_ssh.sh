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
spawn ssh ${1}
expect \"Enter passphrase for key\"
send \"${passphrase}\n\"
expect \"${MARK}\"
send \"sudo su -\n\"
expect \"Password: \"
send \"${passwd}\n\"
expect \"#\"
send \"${2}\n\"
interact
"
