#!/usr/bin/env bash

set -x

current_dnd=$(swaync-client -D)

if [[ "${current_dnd}" == false ]]; then
  notify-send -e "Do not disturbe: ON"
  sleep 3
  swaync-client -d
else
  swaync-client -d
  notify-send -e "Do not disturbe: OFF"
  sleep 3
fi

