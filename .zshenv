# Bootstrap Zsh into the XDG configuration directory.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Zsh chose ~/.zshenv before ZDOTDIR was set, so load the relocated file once.
[[ -r "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
