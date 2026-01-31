#!/usr/bin/env bash

application="launch_tmux_nvim.sh"

### Cleanup parms to not have a hypen
if [[ "$#" -gt 0 ]]; then
  for param in "$@"; do
    if ! echo "$param" | grep -qP -- "-[\w]"; then
      newparams+=("$param")
    fi
  done
  ### Overwrites the original positional params
  set -- "${newparams[@]}"
fi

### Break up arguments for directories and files, otherwise they are not used
if [[ "$#" -gt 0 ]]; then
  for parm in "$@"; do
    if [[ -f "$parm" ]]; then
      #printf "%s is a file, including it nvim command to open it\n" "$parm"
      LASTSCRIPTSDIR="$(readlink -f "$(dirname "$parm")")"
      SCRIPTDIR="$(readlink -f "$parm")"
      nv_parms+=("$SCRIPTDIR")
    else
      #printf "%s is neither a file, including it nvim command to create a new file\n" "$parm"
      new_file="${LASTSCRIPTSDIR}/{$parm}"
      nv_parms+=("$new_file")
    fi
  done
fi

exec xdg-terminal-exec -e -- "${application}" "${nv_parms[@]}" &
sleep 1
