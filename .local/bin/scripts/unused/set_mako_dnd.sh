#!/usr/bin/env bash

set -x

current_mode="$(makoctl mode)"

if [[ "${current_mode}" == "default" ]]; then
  notify-send -e "Do not disturbe: ON"
  sleep 3
  makoctl mode -a do-not-disturb -r default
else
  makoctl mode -a default -r do-not-disturb
  notify-send -e "Do not disturbe: OFF"
  sleep 3
fi

