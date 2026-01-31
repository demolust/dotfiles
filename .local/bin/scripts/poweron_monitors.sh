#!/usr/bin/env bash

set -x

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  niri msg action power-on-monitors
elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
  hyprctl dispatch dpms on
fi

