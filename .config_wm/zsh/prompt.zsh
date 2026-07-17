### Init
autoload -Uz promptinit && promptinit

if [[ "$(command -v starship)" ]]; then
  ### Set prompt to display starship config
  eval "$(starship init zsh)"
fi
