#!/bin/bash

readonly red='0;31'
readonly green='0;32'
readonly brown='0;33'
readonly blue='0;34'
readonly gray='0;37'
readonly org='0;0'

clr_echo ()
{
  msg=${1}
  color=${2:-$(echo $org)}
  echo -e "\033[${color}m${msg}\033[${org}m"
}


CWD=$(cd $(dirname ${0}); pwd)

function main() {
  clr_echo "Backup installed ports..." $brown

  port -qv installed > ${CWD}/myports.txt
  port echo requested | cut -d ' ' -f 1 | uniq > ${CWD}/requested.txt

  clr_echo "Done" $brown
}


main ${@}

# END
