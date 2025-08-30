#!/bin/bash

for monitor in /sys/class/drm/*; do 
  status_file="${monitor}"/status
  if [[ -f "${status_file}" ]]; then
    monitor_status=$(cat "${status_file}") 
    if [[ "${monitor_status}" == "connected" ]];then 
      monitor_name=$(echo "${monitor}" | awk -F '/' '{print $NF}' | cut -d '-' -f 2-)
      connected_monitors+=("${monitor_name}")
    fi
  fi
done

if [[ "${#connected_monitors[@]}" -eq 2 ]] && [[ "${connected_monitors[*]}" =~ .*HDMI.*-1$ ]]; then
  for monitor in "${connected_monitors[@]}"; do
    if [[ "${monitor}" =~ .*HDMI.*-1$ ]]; then
      primary_monitor="${monitor}"
    else
      secondary_monitor="${monitor}"
    fi
  done
  xrandr --output "${primary_monitor}" --auto --primary
  xrandr --output "${secondary_monitor}" --right-of "${primary_monitor}" --auto --noprimary
fi
