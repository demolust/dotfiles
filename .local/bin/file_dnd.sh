#!/bin/bash

set -x
set -euo pipefail

bash_script_path=$(readlink -f "$(dirname "$0")")
dnd_fn="file_dnd.py"

if ! [[ "$(command -v uv)" ]]; then
  printf "Dependencies not installed\n"
  exit 2
fi

if [ ! -f "${bash_script_path}"/"${dnd_fn}" ]; then
  printf "%s does not exists on current dir %s\n" "${dnd_fn}" "${bash_script_path}" 
  exit 3
fi

MODE=$1

if [[ ${MODE} != "once" ]] && [[ ${MODE} != "multi" ]] || [[ -z "$MODE" ]] || [[ -f "$MODE" ]] || [[ -d "$MODE" ]];then
  printf "Script operates with either once or multi as first argument\n"
  exit 3
fi

uv add --script "${bash_script_path}"/"${dnd_fn}" tkinterdnd2
exec uv run "${bash_script_path}"/"${dnd_fn}" "${@}"

