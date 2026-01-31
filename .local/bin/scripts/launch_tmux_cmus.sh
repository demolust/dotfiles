#!/usr/bin/env bash

set -x

uid=$(id -u)
cmus_socket="/run/user/${uid}/cmus-socket"

if tmux has-session -t=cmus; then
	tmux list-clients -t cmus | grep cmus
	if [ $? != 0 ]; then
		exec tmux attach-session -t cmus
	else
		echo "Already attached to cmus session"
    tmux list-clients -t cmus
    ctty=$(tmux list-clients -t cmus | awk -F ":" '{ print $1 }'| cut -d "/" -f 3-)
    tmux detach-client -s cmus
    echo "Kill old client tty that hosted the previous session"
    pkill -e -HUP -t "${ctty}"
    exec tmux attach-session -t cmus
	fi
else
  if [ -S "${cmus_socket}" ]; then
    echo "cmus probably was started manually, either controll with cmus-remote, or search for the terminal with the app"
    sleep 60
    exit 2
  fi
	exec tmux new-session -s cmus -n cmus "cmus"
fi


