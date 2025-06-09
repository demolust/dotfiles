#!/bin/bash

set -x
application="ranger"
current_date=$(date +'%Y-%m-%d_%R:%S')

echo ${PPID}
kill -9 ${PPID}
nohup "${CTERM}" -e "${application}" > /dev/null

