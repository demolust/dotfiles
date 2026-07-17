# Interactive Zsh configuration.
source "$ZSH_CONFIG_DIR/options.zsh"
source "$ZSH_CONFIG_DIR/prompt.zsh"
source "$ZSH_CONFIG_DIR/plugin-manager.zsh"
source "$ZSH_CONFIG_DIR/keyboard.zsh"
source "$ZSH_CONFIG_DIR/history.zsh"
source "$ZSH_CONFIG_DIR/completion.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/integrations.zsh"
source "$ZSH_CONFIG_DIR/plugins.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"
source "$ZSH_CONFIG_DIR/external.zsh"
source "$ZSH_CONFIG_DIR/overrides.zsh"

# Optional private and per-environment configuration.
[[ -r "$XDG_DATA_HOME/secrets/secrets.zsh" ]] &&
  source "$XDG_DATA_HOME/secrets/secrets.zsh"

[[ -r "$XDG_DATA_HOME/zsh/envs.zsh" ]] &&
  source "$XDG_DATA_HOME/zsh/envs.zsh"
