# Environment configuration loaded by every Zsh process.
export ZSH_CONFIG_DIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

source "$ZSH_CONFIG_DIR/env/xdg.zsh"

export ZDOTDIR="$ZSH_CONFIG_DIR"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$XDG_CACHE_HOME/zsh}"
export ZSH_DATA_DIR="${ZSH_DATA_DIR:-$XDG_DATA_HOME/zsh}"
export ZSH_STATE_DIR="${ZSH_STATE_DIR:-$XDG_STATE_HOME/zsh}"

source "$ZSH_CONFIG_DIR/env/paths.zsh"
source "$ZSH_CONFIG_DIR/env/programs.zsh"
source "$ZSH_CONFIG_DIR/env/desktop.zsh"
