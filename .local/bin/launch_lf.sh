#!/bin/bash

set -x
application="lf"
current_date=$(date +'%Y-%m-%d_%R:%S')

echo ${PPID}
kill -9 ${PPID}
nohup "${CTERM}" -e "${application}" > /dev/null

