#!/usr/bin/env bash

if ! [[ "$(command -v fzf)" ]]; then
  printf "Dependencies not installed\n"
  exit 2
fi

header_msg="Select device to unmount: "
selection=$(lsblk -nA -o PATH,MOUNTPOINT | grep "$USER" | fzf --reverse --tmux=center,85%,50% --border rounded --header="${header_msg}" --no-input --bind='k:up' --bind='j:down')

if [ -z "$selection" ]; then
  echo "No device selection made exit"
  exit 0
fi

device=$(echo "$selection" | awk '{print $1}')

if lsof "$device" > /dev/null; then
  echo "There are open files on the device, can't unmount"
  lsof "$device"
  sleep 15
  exit 1
fi

udisksctl unmount --no-user-interaction -b "$device"

