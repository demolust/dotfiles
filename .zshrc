# zsh customization options

############################### PROMPT CUSTOMIZATION ################################
### Disable flow control since is not needed
stty -ixon

### Unset beep on errors
unsetopt beep

### Init
autoload -Uz promptinit && promptinit

if [[ "$(command -v starship)" ]]; then
  ### Set prompt to display starship config
  eval "$(starship init zsh)"
fi

############################### PLUGIN MANAGER CONFIG ###############################
### Set the directory where zinit and the plugins will be stored
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
ZINIT_CACHE_DIR="${XDG_CACHE_HOME}/zinit"

### Ensure zinit is always present by git cloning it
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

### Source zinit
source "${ZINIT_HOME}/zinit.zsh"

### Create the zinit snippet completitions cache directory
ZINIT_CACHE_DIR_COMPLETITIONS="${ZSH_CACHE_DIR}/completions"
if [ ! -d "${ZINIT_CACHE_DIR_COMPLETITIONS}" ]; then
  mkdir -p "${ZINIT_CACHE_DIR_COMPLETITIONS}"
fi

#################################### CUSTOM KEYS ####################################
### To list all commands `zle -al` that can be mapped to a key binding
### To view all current applied binkeys `bindkey -L`

### Set termianl to act as an emacs
bindkey -e

### FROM ARCH WIKI (1)
# https://wiki.archlinux.org/title/zsh#Key_bindings

# create a zkbd compatible hash;  to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

### For xterm-compatible terminals extended key-definitions
key[CtrlLft]="${terminfo[kLFT5]}"
key[CtrlRft]="${terminfo[kRIT5]}"
key[CtrlDel]="${terminfo[kDC5]}"
key[CtrlUp]="${terminfo[kUP5]}"
key[CtrlDwn]="${terminfo[kDN5]}"

# This combinations may need to be tested
key[ShftCtrlLft]="${terminfo[kLFT6]}"
key[ShftCtrlRft]="${terminfo[kRIT6]}"

### This defeinitons can be found over
# https://wiki.archlinux.org/title/zsh#Shift,_Alt,_Ctrl_and_Meta_modifiers
# https://man.archlinux.org/man/user_caps.5#Extended_key-definitions
# https://stackoverflow.com/questions/31379824/how-to-get-control-characters-for-ctrlleft-from-terminfo-in-zsh

# setup key accordingly
### Set `Home` to got beginning to the of line
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
### Set `End` to got to the end of line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
### Set
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
### Set `Backspace` to normal behavior, which is delete backward
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
### Set `Delete` to remove a single char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
### Set Arrow keys
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
### Set `PageUp` to get to the begining of history
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
### Set `PageDown` to get to the ending of history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
### Set `Shift+Tab` to reverse completion
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete


if [[ -n $TERM && $TERM == *"xterm"* ]]; then
  ### For xterm-compatible terminals extended key-definitions
  ### Set `Ctrl + LeftArrow` to move backwards between words
  [[ -n "${key[CtrlLft]}" ]] && bindkey -- "${key[CtrlLft]}"  backward-word
  ### Set `Ctrl + RightArrow` to move foward between words
  [[ -n "${key[CtrlRft]}" ]] && bindkey -- "${key[CtrlRft]}"  forward-word
  ### Set `Ctrl + Delete` to remove a word
  [[ -n "${key[CtrlDel]}" ]] && bindkey -- "${key[CtrlDel]}"  delete-word

  ### Set history search backward & foward using Ctrl + Up/Down Arrowkeys
  #this is based from the cursor position and what is written until that point
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search

  ### Set `Ctrl + UpArrow` to search upwards for similar witten command
  [[ -n "${key[CtrlUp]}"  ]] && bindkey -- "${key[CtrlUp]}"  up-line-or-beginning-search
  ### Set `Ctrl + DownArrow` to search downwards for similar witten command
  [[ -n "${key[CtrlDwn]}" ]] && bindkey -- "${key[CtrlDwn]}" down-line-or-beginning-search

fi

# Finally, make sure the terminal is in application mode, when zle is active
# Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

### MANUAL CUSTOM KEYS SETUP
### Overwrite `Ctrl + p` to behave like `Ctrl + Shift + UpArrow`
bindkey '^p' up-line-or-beginning-search
### Overwrite `Ctrl + n` to behave like `Ctrl + Shift + DownArrow`
bindkey '^n'  down-line-or-beginning-search
### To find which char combinations represents a key or key combination first use `Ctrl + v` or the `read` command, then input the desired key or key combinations
### Set `Ctrl-u` to kill from current cursor position to the begining of the line '\C-u'
bindkey "^U" backward-kill-line
### Set `Ctrl-k` to kill from current cursor position to the ending of the line '\C-k'
bindkey "^K" kill-line
# `Ctrl-x, Ctrl-e` - Edit the current command line in $EDITOR '\C-x\C-e'
autoload -U edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
# `Ctrl + Backspace` - Deletes one word backwards, from the current cursor location
bindkey "^H" backward-kill-word

## Make EMACS mode more similar to VIM Normal Mode
# `Ctrl + ^` Moves to the beginning-of the line (Similar as VIM Normal Mode)
bindkey "^^" beginning-of-line
# `Alt + $` Moves forward to the end of the end (Similar as VIM Normal Mode)
bindkey "^[$" end-of-line

### WELL KONWN STANDARD SHORTCUTS
### Alt can be substituted with Esc
# `Ctrl + a` ---> Moves the cursor to the beginning of the line
# `Ctrl + e` ---> Moves the cursor to the end of the line
# `Ctrl + w` ---> Deletes the one word backwards from the cursor location
# `Ctrl + k` ---> Kills (or deletes) until the end of the line
# `Ctrl + r` ---> Incremental search backwards
# `Ctrl + s` ---> Incremental search forwards (automatically enables NO_FLOW_CONTROL option)
# `Ctrl + d` ---> Deletes a character (moves forward) / lists completions / logs out
# `Ctrl + f` ---> Moves the cursor forward one character
# `Ctrl + y` ---> Yanks the last killed word
# `Ctrl + t` ---> Transposes/Swaps two characters
# `Alt  + t` ---> Transposes/Swaps two words
# `Alt  + d` ---> Deletes one word on the right of the cursor
# `Alt  + b` ---> Moves the cursor backwards one word
# `Alt  + f` ---> Moves the cursor forward one word
# `Alt  + u` ---> Capitalize word to the right
# `Alt  + l` ---> Uncapitalize word to the right
# `Alt  + y` ---> Switches the last yanked word
# `Alt  + a` ---> Enter a new line, execute the command and reposition everything
# `Alt  + Backspace` ---> Deletes one word backwards, from the cursor location

### SOME OTHER DEFINITIONS
# `Alt  + p` ---> Behaves like `Ctrl + p`
# `Alt  + n` ---> Behaves like `Ctrl + n`

### REPLACED FROM THE STANDARD DEFINITION
# `Ctrl + u` ---> Deletes the whole line
# `Ctrl + b` ---> Moves the cursor backwards one character
################################# HISTORY SETTINGS ##################################
### Set history saving
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=$HISTSIZE

# Share history between all sessions
setopt SHARE_HISTORY
# Write to the history file immediately, not when the shell exits
setopt INC_APPEND_HISTORY
# Do not record an entry that was just recorded again
setopt HIST_IGNORE_DUPS
# Do not write duplicate entries in the history file
setopt HIST_SAVE_NO_DUPS

# Expire duplicate entries first when trimming history
#setopt HIST_EXPIRE_DUPS_FIRST
# Delete old recorded entry (in the shell history) if new entry is a duplicate
#setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found
#setopt HIST_FIND_NO_DUPS
# Do not record an entry starting with a space
#setopt HIST_IGNORE_SPACE
# Remove superfluous blanks before record
#setopt HIST_REDUCE_BLANKS

################################ COMPLETITION SETUP #################################
### Init completion
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

### Zstyles are defined via the zstyle keyword, followed by a colon-delimited list of arguments:
###   :completion:function:completer:command:argument:tag

### For autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select

### Make the commands show the breif descriptions of their arguments when cycling them with autocompletion
zstyle ':completion:*' verbose yes

### This allows completion to be able to correct any misspelled commands
zstyle ':completion:*' completer _expand _complete _correct

### Completition for elevated commands
#zstyle ':completion::complete:*' gain-privileges 1

### Case insesitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

### Add colors to completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

####################################### ALIAS #######################################
### Custom home only aliases
alias pi='ssh pi'
alias pizero='ssh pizero'
alias d7050='ssh d7050'

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

### Set command aliases
### Sets yt-dlp to download 10 files at time & to retry infinitie times any given part of the file in case it fails
if [[ "$(command -v yt-dlp)" ]]; then
  alias yt-dlp='yt-dlp -N 10 -R infinite'
fi

#### Use vlc with ani-cli
if [[ "$(command -v ani-cli)" ]]; then
  alias ani-cli='ani-cli -v'
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
  alias ls='eza -gH --color=always'
  alias ll='eza -lgH --color=always'
  alias l='eza -lgHA --color=always'
  alias l.='eza -d .* --color=always'
  alias tree='eza -a -I ".git|node_modules|venv" --tree --color=always'
fi

if [[ "$(command -v git_remove_untracked_fzf.sh)" ]]; then
  alias grmui=git_remove_untracked_fzf.sh
fi

if [[ "$(command -v git_remove_fzf.sh)" ]]; then
  alias grmi=git_remove_fzf.sh
fi

### Add plugins via zinit
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  ### Enables new additional completion definitions for zsh
  zinit light zsh-users/zsh-completions
  ### Provides syntax highlighting of commands for the shell zsh
  zinit light zsh-users/zsh-syntax-highlighting
  ### Enables Fish-like fast/unobtrusive autosuggestions for zsh, first clone repo as
  zinit light zsh-users/zsh-autosuggestions
  ### `fzf-tab` enables completion selection menu with fzf
  zinit light Aloxaf/fzf-tab
  ### `fzf-git` enables git completion selection menu with fzf
  zinit light junegunn/fzf-git.sh

  ### `forgit` enables to use git interactively with fzf
  ### Flags for this plugin must be enabled before sourcing it
  export FORGIT_LOG_GRAPH_ENABLE=false
  export FORGIT_NO_ALIASES=true
  export FORGIT_FZF_DEFAULT_OPTS="
  --border rounded
  --reverse
  "
  export FORGIT_LOG_FZF_OPTS='
  --header "Open log with nvim: <Ctrl> + <e>"
  --bind="ctrl-e:execute(echo {} | grep -Eo [a-f0-9]+ | head -1 | xargs git show | nvim -)"
  '
  zinit load wfxr/forgit

  ### Override aliases to `orginal_alias`+i
  alias gai="forgit::add"
  alias gloi="forgit::log"
  alias gbdi="forgit::branch::delete"
  alias gbli="forgit::blame"
  alias gcbi="forgit::checkout::branch"
  alias gcfi="forgit::checkout::file"
  alias gcoi="forgit::checkout::commit"
  alias gcpi="forgit::cherry::pick::from::branch"
  alias gdi="forgit::diff"
  alias gii="forgit::ignore"
  alias grbii="forgit::rebase"
  alias grhi="forgit::reset::head"
  alias gssi="forgit::stash::show"
  alias gcleani="forgit::clean"
  ### If normal alias are set the following orginal alias needs to unset
  ### As no similar alias is in use on OMZP::git
  alias gcti="forgit::checkout::tag"
  alias gfui="forgit::fixup"
  alias grci="forgit::revert::commit"
  alias gspi="forgit::stash::push"

  ### zsh-users/zsh-syntax-highlighting Customize command colors
  ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,underline
  ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,underline
  ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
  ZSH_HIGHLIGHT_STYLES[assign]=fg=green

  ### Aloxaf/fzf-tab integration
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

  ### Add in custom alias & snippets
  ### https://github.com/ohmyzsh/ohmyzsh/wiki/plugins
  ### Local sysadmin related snippets
  zinit snippet OMZP::ssh
  zinit snippet OMZP::sudo
  zinit snippet OMZP::nmap
  zinit snippet OMZP::rsync
  zinit snippet OMZP::systemd
  zinit snippet OMZP::systemadmin
  zinit snippet OMZP::firewalld
  zinit snippet OMZP::ssh-agent
  zinit snippet OMZP::gpg-agent
  #zinit snippet OMZP::command-not-found
  #zinit snippet OMZP::tmux

  ### Local syntax errors snippets
  #zinit snippet OMZP::ufw

  ### Programming related snippets
  zinit snippet OMZP::git
  zinit snippet OMZP::git-commit
  zinit snippet OMZP::rust
  zinit snippet OMZP::perl
  zinit snippet OMZP::python
  zinit snippet OMZP::golang
  zinit snippet OMZP::dotnet

  ### DevOps tools related snippets
  ### Cloud CLI's snippets
  zinit snippet OMZP::aws
  zinit snippet OMZP::azure
  zinit snippet OMZP::doctl
  zinit snippet OMZP::gcloud
  ### IaC snippets
  zinit snippet OMZP::oc
  zinit snippet OMZP::vagrant
  zinit snippet OMZP::ansible
  zinit snippet OMZP::terraform
  zinit snippet OMZP::knife_ssh
  ### Kubernetes snippets
  zinit snippet OMZP::kops
  zinit snippet OMZP::kubectl
  zinit snippet OMZP::minikube
  zinit snippet OMZP::microk8s
  ### Containers snippets
  zinit snippet OMZP::lxd
  zinit snippet OMZP::podman
  zinit snippet OMZP::docker-compose
  ## DB snippets
  zinit snippet OMZP::mongocli
  zinit snippet OMZP::postgres
  ### Other DevOps snippets
  #zinit snippet OMZP::localstack

  ### DevOps errors snippets
  #zinit snippet OMZP::knife
  #zinit snippet OMZP::salt
  #zinit snippet OMZP::redis-cli
  #zinit snippet OMZP::kitchen

  ### Needs docker not podman/docker
  #zinit snippet OMZP::docker

  ### Other tools related snippets
  zinit snippet OMZP::gh
  zinit snippet OMZP::jira
  zinit snippet OMZP::procs
  zinit snippet OMZP::isodate
  zinit snippet OMZP::toolbox
  #zinit snippet OMZP::sigstore

  zinit cdreplay -q

fi

################################### USER FUNCTIONS ##################################
### Function that calls cd, and immediately list its contents
function cs {
  cd "$@" && ls -A
}

function lazygp {
  git add .
  git commit -m "$@"
  git push
}

############################### EXTERNAL DELCARATIONS ###############################
### Section for settings & customization for external programs that relies on zsh with some event/falg
### Such as on tmux plugins or nvim plugins

### Settings for ofirgall/tmux-window-name
### Install first `python3 -m pip install --user libtmux`
#function tmux-window-name() {
#	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
#}
#add-zsh-hook chpwd tmux-window-name

################################# SETTINGS OVERRIDE #################################
### Section that overrides some plugin settings
unalias mkdir
alias mkdir='mkdir -p'

################################### USER SETTINGS ###################################
### User settings such as PATHS, VARIABLES, and so on, are defined at ~/.zshenv, wich is loaded before this file
### This is done as zsh can be used to spwan new procceses that inherits those settings

