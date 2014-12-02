#!/bin/bash

TEMP_PASSWD=/tmp/_passwd

source $TEMP_PASSWD

expect -c "
set timeout 10
spawn ssh ${1}
expect \"Enter passphrase for key\"
send \"${passphrase}\n\"
expect \"%\"
send \"sudo su -\n\"
expect \"Password: \"
send \"${passwd}\n\"
expect \"#\"
send \"${2}\n\"
interact
"
