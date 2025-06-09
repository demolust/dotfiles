#!/bin/sh

script_path=$(readlink -f "$(dirname "$0")")
curr_date=$(date +'%Y_%m_%d_%R:%S')

if [ -z "$XDG_CACHE_HOME" ]; then
  XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
fi
IMAGE_CACHE_PATH="$XDG_CACHE_HOME/lf"

[ -d "${IMAGE_CACHE_PATH}" ] || mkdir -p -- "${IMAGE_CACHE_PATH}"

if ! [ "${DEBUG_LF_PREV}" ]; then
  "${script_path}/scope.sh" "${1}" "${2}" "${3}" "${4}" "${5}" "${IMAGE_CACHE_PATH}" "${PV_IMAGE}"
else
  "${script_path}/scope.sh" "${1}" "${2}" "${3}" "${4}" "${5}" "${IMAGE_CACHE_PATH}" "${PV_IMAGE}" 2> "${TMPDIR:-/tmp}/lf_${curr_date}_scope_out.log"
fi
