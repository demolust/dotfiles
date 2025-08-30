#!/bin/bash

set -x
application="launch_tmux_lf.sh"
CTERMS="wezterm-gui"

echo ${PPID}
exec "${CTERMS}" start -- "${application}" &
sleep 1

