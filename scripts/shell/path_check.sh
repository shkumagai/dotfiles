#!/bin/bash
# shellcheck disable=SC2164

echo "              dirname \$0 #=>" "$(dirname "${0}")"
echo "                    \$PWD #=>" "${PWD}"
echo "\$(cd \$(dirname \$0); pwd) #=>" "$(cd "$(dirname "${0}")"; pwd)"
