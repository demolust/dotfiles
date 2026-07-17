##################################### PATH SETUP #####################################
CARGO_HOME="$XDG_DATA_HOME"/cargo
GOPATH="$XDG_DATA_HOME"/go
CUSTOM_SCRIPTS="$HOME/.local/bin/scripts"

export PATH="$HOME/.local/bin:${GOPATH}/bin:${CARGO_HOME}/bin:/var/lib/flatpak/exports/bin:/usr/local/bin:$CUSTOM_SCRIPTS:$PATH"

