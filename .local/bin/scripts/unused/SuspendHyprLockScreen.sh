#!/usr/bin/env bash

set -x

if systemctl --user -q is-active hyprlock.service; then
  exit 0
fi

last_active=$(systemctl --user status hyprlock.service | grep Consumed | tail -n 1 | sed "s/ $HOSTNAME.*//")
if [[ -z "${last_active}" ]]; then
  systemctl --user start hyprlock.service
fi
last_active_epoch_sec=$(date -d "${last_active}" +%s)
elapsed_sec=$(( $(date +%s) - last_active_epoch_sec ))
if [[ ${elapsed_sec} -ge 30 ]]; then
  systemctl --user start hyprlock.service
fi


