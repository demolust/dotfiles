#!/bin/bash

set -x

if ! systemctl --user is-active hyprlock.service; then
  systemctl --user start hyprlock.service
fi
