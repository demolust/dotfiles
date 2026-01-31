#!/usr/bin/env bash

set -x

num=$(tmux list-session | grep -c lf_session)
num=$((num+1))
exec tmux new-session -s "lf_session_${num}" -n lf "lfi"

