#!/bin/bash

set -x
application="nvim"
CTERMS="wezterm-gui"
current_date=$(date +'%Y-%m-%d_%R:%S')

#echo ${PPID}
#kill -9 ${PPID}
nohup "${CTERMS}" start -- "${application}" > /dev/null

