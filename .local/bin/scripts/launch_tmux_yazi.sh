#!/usr/bin/env bash

set -x

num=$(tmux list-session | grep -c yazi_session)
num=$((num+1))
exec tmux new-session -s "yazi_session_${num}" -n yazi "yazi"

