#!/usr/bin/env bash

source "$(dirname "$0")"/monitors_info.sh

if ! systemctl --user -q is-active swayosd.service; then
  systemctl --user start swayosd.service
fi

swayosd-client --monitor "${focused_monitor}" "$@"

