#!/usr/bin/env bash

set -euf
set -x

TEMP_LOCK_FILE="/tmp/set_wallpaper.lock"

CONFDIR="${XDG_CONFIG_HOME}/hypr"
CONF_FILE="${CONFDIR}/hyprlock.conf"

CACHEDIR="${XDG_CACHE_HOME}/hyprlock"
if [ ! -d "$CACHEDIR" ]; then
  mkdir -p "$CACHEDIR"
fi

WALLPAPER_FILE_ORG="${CACHEDIR}/hyprlock.jpg"
WALLPAPER_FILE="${CACHEDIR}/hyprlock.png"

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

if ! [ -f "${CONF_FILE}" ]; then
  fatal "${CONF_FILE}, dosen't exists, can't set set wallpaper to it"
fi

sed -i 's|path = .*|path = $HOME/.cache/hyprlock/hyprlock.png|g' "${CONF_FILE}"

info "Done setting wallpaper"

