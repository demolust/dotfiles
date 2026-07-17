# Bootstrap login Bash into the XDG configuration directory.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"

[[ -r "$BASH_CONFIG_DIR/.bash_profile" ]] &&
  source "$BASH_CONFIG_DIR/.bash_profile"
