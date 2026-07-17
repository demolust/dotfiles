################################# SETTINGS OVERRIDE #################################
### Section that overrides some plugin settings
unalias mkdir
alias mkdir='mkdir -p'
if [ "$(command -v prettyping)" ]; then
  unalias ping
  alias ping=prettyping
fi
