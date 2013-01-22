#!/bin/bash

echo "              dirname \$0 #=>" `dirname $0`
echo "                    \$PWD #=>" $PWD
echo "\$(cd \$(dirname \$0); pwd) #=>" $(cd $(dirname $0); pwd)
