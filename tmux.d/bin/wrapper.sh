#!/bin/bash

CWD=$(cd $(dirname $0); pwd)
TMUX_ROOT=$(cd $CWD/..; pwd)

TARGET=${1}
SESSION_NAME=${TARGET}

tmux -u2 new -s ${SESSION_NAME%%.*} "bash ${TMUX_ROOT}/bin/${TARGET}"
