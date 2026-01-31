#!/usr/bin/env bash

set -euf
set -x

TEMP_LOCK_FILE="/tmp/set_wallpaper.lock"

CACHEDIR="${XDG_CACHE_HOME}/niri"
if [ ! -d "$CACHEDIR" ]; then
  mkdir -p "$CACHEDIR"
fi
WALLPAPER_FILE="${CACHEDIR}/tmp.jpg"

fatal() {
  echo "|FATAL|" "$@" >&2
  exit 1
}

info() {
  echo "|INFO|" "$@"
}

cleanup() {
  rm -f -- "${TEMP_LOCK_FILE}"
}

trap cleanup HUP INT QUIT TERM EXIT

info "Cheking if lock exists"
until ! [ -f "${TEMP_LOCK_FILE}" ]; do
  info "Lock is in place, sleeping for 30s to wait for it to be removed"
  sleep 30
done

info "Starting set up for wallpaper, creating lock"
touch "${TEMP_LOCK_FILE}"

if ! [ -f "${WALLPAPER_FILE}" ]; then
  fatal "${WALLPAPER_FILE}, dosen't exists, can't set it"
fi

set +e
if ps -fC swaybg; then
  pkill swaybg
fi
set -e

exec swaybg -m fill -i "${WALLPAPER_FILE}" &
info "Done setting wallpaper"

