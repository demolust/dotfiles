#!/usr/bin/env bash

INSTALL_DIR="$HOME/.local/bin/scripts"
[ -d  "$INSTALL_DIR" ] || mkdir -p "$INSTALL_DIR"
SCRIPT_DEST="${INSTALL_DIR}/prettyping"
RAW_GIT_URL="https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping"

printf "Checking if prettyping is already installed\n"
if [ ! -f "${SCRIPT_DEST}" ]; then
  printf "Installing prettyping on %s\n" "${INSTALL_DIR}"
  curl -fSsL "${RAW_GIT_URL}" -o "${SCRIPT_DEST}" 
  chmod 755 "${SCRIPT_DEST}"
fi
