#!/usr/bin/env bash

set -euf
set -x

TEMP_LOCK_FILE="/tmp/set_wallpaper.lock"

HYPRLAND_CACHEDIR="${XDG_CACHE_HOME}/hyprland"
if [ ! -d "$HYPRLAND_CACHEDIR" ]; then
  mkdir -p "$HYPRLAND_CACHEDIR"
fi

WALLPAPER_FILE_ORG="${HYPRLAND_CACHEDIR}/tmp.jpg"
WALLPAPER_FILE="${HYPRLAND_CACHEDIR}/hyprland.png"

MIMETYPE="$(file --dereference --brief --mime-type -- "${WALLPAPER_FILE_ORG}")"
if [[ "${MIMETYPE}" = *png ]]; then
  rsync -havzP "${WALLPAPER_FILE_ORG}" "${WALLPAPER_FILE}"
else
  magick convert -- "${WALLPAPER_FILE_ORG}" "${WALLPAPER_FILE}"
fi

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

