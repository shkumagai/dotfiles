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
  clr_echo "Restore installed ports..." "${brown}"

  sudo port -f uninstall installed
  curl --location --remote-name "https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl"
  chmod +x "${CWD}"/restore_ports.tcl
  # xattr -d com.apple.quarantine restore_ports.tcl
  sudo "${CWD}/restore_ports.tcl ${CWD}/myports.txt"

  sudo port unsetrequested installed
  xargs sudo port setrequested < "${CWD}/requested.txt"

  clr_echo "Done" "${brown}"
}


main "${@}"

# END
