#!/usr/bin/env bash

set -x
application="launch_tmux_ranger.sh"
echo ${PPID}
exec xdg-terminal-exec -e -- "${application}" &
sleep 1
