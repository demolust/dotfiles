#!/usr/bin/env bash

if [[ -z "${XDG_DATA_HOME}" ]]; then
  XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
fi

printf "Checking if tpm is already installed\n"

TMUX_PLUGINS_BASEPATH="$XDG_DATA_HOME/tmux/plugins"
if [ ! -d "${TMUX_PLUGINS_BASEPATH}/tpm" ]; then
  mkdir -p "$TMUX_PLUGINS_BASEPATH"
  git clone https://github.com/tmux-plugins/tpm "${TMUX_PLUGINS_BASEPATH}/tpm"
fi
