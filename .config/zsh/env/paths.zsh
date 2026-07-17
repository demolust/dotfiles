##################################### PATH SETUP #####################################
### PATH on zsh is controlled by a named array called path
CARGO_HOME="$XDG_DATA_HOME"/cargo
GOPATH="$XDG_DATA_HOME"/go
CUSTOM_SCRIPTS="$HOME/.local/bin/scripts"

typeset -U path PATH
path=(~/.local/bin "${GOPATH}"/bin "${CARGO_HOME}"/bin /var/lib/flatpak/exports/bin "$CUSTOM_SCRIPTS" $path)
export PATH

