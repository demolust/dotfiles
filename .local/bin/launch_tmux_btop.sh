#!/bin/bash

set -x

num=$(tmux list-session | grep -c btop_session)
num=$((num+1))
exec tmux new-session -s "btop_session_${num}" -n btop "btop"

