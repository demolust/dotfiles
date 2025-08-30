#!/bin/bash
# Modified Script for Google Search
# Original Submitted by https://github.com/LeventKaanOguz
# Opens rofi in dmenu mod and waits for input. Then pushes the input to the query of the URL.

set -x

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  unset XDG_CURRENT_DESKTOP
fi


rofi_config="${XDG_CONFIG_HOME}/rofi/config-search.rasi"
    
# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
  pkill rofi
fi

# Open rofi with a dmenu and pass the selected item to xdg-open for Google search
result=$(rofi -dmenu -config "${rofi_config}")

if [ -z "${result}" ]; then
  exit 0
fi

xdg-open "https://www.google.com/search?q=${result}"

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  sleep 2
  window_id=$(niri msg windows | grep -B 1 -P "Title:.*${result}.*Google.*" | grep "Window ID" | awk '{print $3}' | cut -d ":" -f 1)
  sleep 1
  current_window_id=$(niri msg focused-window | grep "Window ID" | awk '{print $3}' | cut -d ":" -f 1)
  if [[ "${window_id}" != "${current_window_id}" ]]; then
    niri msg action focus-window --id "${window_id}"
  fi
fi

