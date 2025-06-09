#!/bin/bash

set -x

num=$(tmux list-session | grep -c ranger_session)
num=$((num+1))
exec tmux new-session -s "ranger_session_${num}" -n ranger "ranger"

