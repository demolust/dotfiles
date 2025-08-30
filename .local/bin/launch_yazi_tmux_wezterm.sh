#!/bin/bash

set -x
application="launch_tmux_yazi.sh"
CTERMS="wezterm-gui"

echo ${PPID}
exec "${CTERMS}" start -- "${application}" & 
sleep 1

