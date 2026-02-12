#!/usr/bin/env bash

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TMUX_PLUGINS_BASEPATH="$XDG_DATA_HOME/tmux/plugins"

printf "Checking if tpm is already installed\n"
if [ ! -d "${TMUX_PLUGINS_BASEPATH}/tpm" ]; then
  printf "Installing tpm on %s/tpm\n" "${TMUX_PLUGINS_BASEPATH}"
  mkdir -p "$TMUX_PLUGINS_BASEPATH"
  git clone https://github.com/tmux-plugins/tpm "${TMUX_PLUGINS_BASEPATH}/tpm"
fi
