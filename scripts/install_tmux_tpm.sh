#!/usr/bin/env bash

printf "Checking if tpm is already installed\n"

if [ ! -d ~/.local/share/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
fi
