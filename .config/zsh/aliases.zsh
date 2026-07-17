####################################### ALIAS #######################################
### Basic aliases
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias l='ls -lA'
alias l.='ls -d .*'
alias ll='ls -l'
alias ip='ip --color=auto'
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../.."
alias -- +=pushd
alias -- -=popd
alias gs='git status'

### Local LLM alias
alias ai-local-on="systemctl --user start container-ollama"
alias ai-local-off="systemctl --user stop container-ollama"
alias ollama='podman exec -it ollama ollama'

### Set command aliases
### Sets yt-dlp to download 10 files at time & to retry infinitie times any given part of the file in case it fails
if [[ "$(command -v yt-dlp)" ]]; then
  alias yt-dlp='yt-dlp -N 10 -R infinite'
fi

#### Setup colors in ncdu
if [[ "$(command -v ncdu)" ]]; then
  alias ncdu='ncdu --color dark'
fi

if [[ "$(command -v lazygit)" ]]; then
  alias lg="lazygit"
fi

if [[ "$(command -v bat)" ]]; then
  alias cat="bat -P --style 'header,grid'"
fi

if [[ "$(command -v trash)" ]]; then
  alias rm="trash"
fi

if [[ "$(command -v nvim)" ]]; then
  ### Suposse NvChad v2.0 is already installed and configured
  export MANPAGER='nvim +Man!'
  alias v=nvim
  alias vi=nvim
  alias vim=nvim
  alias vdiff='nvim -d'
  alias vidiff='nvim -d'
  alias vimdiff='nvim -d'
  alias nv=nvim
elif [[ "$(command -v vim)" ]]; then
  alias v=vim
  alias vi=vim
  alias vdiff='vimdiff'
  alias vidiff='vimdiff'
fi

if [[ "$(command -v rifle)" ]]; then
  ### Suposse rifle.conf already configured as per the system
  alias o='rifle -p 0'
  alias open='rifle -p 0'
fi

### Setup alias to paly/pause the music in cmus within the cli using cmus-remote, for this a cmus instance must be already running
if [[ "$(command -v cmus)" ]]; then
  alias cpa="cmus-remote -U"
  alias cpl="cmus-remote -p"
fi

