#!/usr/bin/env bash

set -x
application="launch_tmux_btop.sh"
echo ${PPID}
exec xdg-terminal-exec -e -- "${application}" &
sleep 1
