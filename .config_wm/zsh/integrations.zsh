######################## ENABLE SHELL INTEGRATIONS & PLUGINS ########################
### Enable zoxide integrations, needs zoxide v0.9.4 or higher
### It enables to "jump" to the must used directories in just a few keystrokes
### A path confusion can occurr when different paths have a similar namepart in common between them
### To solve it use <Space> then <Tabs> to enter interactive mode and select the desired path to cd into
### This can happen in the case of cd into all of `/usr/bin`, `/bin`, `~/.local/bin`
### The second option to resolve the path confusion is to use the interactive version (zi/cdi)
if [[ "$(command -v zoxide)" ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi

### Enable fzf integrations, needs fzf v0.48 or higher
### It enables fuzzy reverse history search
if [[ "$(command -v fzf)" ]]; then
  eval "$(fzf --zsh)"
fi

if [[ "$(command -v thefuck)" ]]; then
  eval $(thefuck --alias)
  alias f=fuck
  export THEFUCK_EXCLUDE_RULES="fix_file"
fi

if [[ "$(command -v direnv)" ]]; then
  eval "$(direnv hook zsh)"
fi

if [[ "$(command -v tldr)" ]]; then
  export TLDR_CACHE_ENABLED=1
  export TLDR_CACHE_MAX_AGE=720
fi

if [[ "$(command -v git)" && "$(command -v delta)" ]]; then
  export GIT_PAGER=delta
elif [[ "$(command -v git)" ]]; then
  export GIT_PAGER=$(which less)
fi

if [[ "$(command -v eza)" ]]; then
  export EZA_COLORS="da=38;5;252:sb=38;5;204:sn=38;5;43:xa=8:\
  uu=38;5;245:un=38;5;241:ur=38;5;223:uw=38;5;223:ux=38;5;223:ue=38;5;223:\
  gr=38;5;153:gw=38;5;153:gx=38;5;153:tr=38;5;175:tw=38;5;175:tx=38;5;175:\
  gm=38;5;203:ga=38;5;203:mp=3;38;5;111:im=38;2;180;150;250:vi=38;2;255;190;148:\
  mu=38;2;255;175;215:lo=38;2;255;215;183:cr=38;2;240;160;240:\
  do=38;2;200;200;246:co=38;2;255;119;153:tm=38;2;148;148;148:\
  cm=38;2;230;150;210:bu=38;2;95;215;175:sc=38;2;110;222;222"
  alias ls='eza -gH --color=auto'
  alias ll='eza -lgH --color=auto'
  alias lll='eza -1gH --color=auto'
  alias llll='eza -1gHA --color=auto'
  alias l='eza -lgHA --color=auto'
  alias l.='eza -d .* --color=auto'
  alias tree='eza -a -I ".git|node_modules|venv" --tree --color=auto'
fi

if [[ "$(command -v git_remove_untracked_fzf.sh)" ]]; then
  alias grmui=git_remove_untracked_fzf.sh
fi

if [[ "$(command -v git_remove_fzf.sh)" ]]; then
  alias grmi=git_remove_fzf.sh
fi

