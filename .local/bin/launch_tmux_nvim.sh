#!/bin/bash

set -x

num=$(tmux list-session | grep -c nvim_session)
num=$((num+1))
exec tmux new-session -s "nvim_session_${num}" -n nvim "nvim" "$@"

