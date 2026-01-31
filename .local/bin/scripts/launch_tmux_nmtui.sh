#!/usr/bin/env bash

set -x

num=$(tmux list-session | grep -c nmtui_session)
num=$((num+1))
exec tmux new-session -s "nmtui_session_${num}" -n nmtui "nmtui"

