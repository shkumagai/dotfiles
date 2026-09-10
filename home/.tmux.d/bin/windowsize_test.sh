#!/bin/bash

set

echo "$@"

# shellcheck disable=SC2046
set -- $(stty size)
rows=${1}
cols=${2}
echo "rows: ${rows}, cols: ${cols}"

echo "$@"


per_host=$(( (rows - 6) / 6 ))
echo "rows per host: ${per_host}"
