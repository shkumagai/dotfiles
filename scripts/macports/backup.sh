#!/bin/bash

readonly green='0;32'
readonly brown='0;33'
readonly org='0;0'


clr_echo ()
{
  msg=${1}
  color=${2:-"${org}"}
  printf "\033[${color}m%s\033[${org}m\n" "${msg}"
}

# shellcheck disable=SC2164
CWD=$(cd "$(dirname "${0}")"; pwd)

function main() {
  clr_echo "Backup installed ports..." "${brown}"

  port -qv installed > "${CWD}/myports.txt"
  port echo requested | cut -d ' ' -f 1 | uniq > "${CWD}/requested.txt"

  clr_echo "Done" "${brown}"
}


main "${@}"

# END
