#!/usr/bin/env bash

set -x
systemctl --user stop unoserver.service

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  niri msg action quit -s
elif [[ "$DESKTOP_SESSION" == "hyprland-uwsm" ]]; then
  uwsm stop
elif [[ "$DESKTOP_SESSION" == "Hyprland" ]]; then
  killall -9 Hyprland
fi

