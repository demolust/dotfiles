################################### USER SETTINGS ###################################
### User settings such as PATHS, VARIABLES, and so on, are defined at here

################################### XDG DEFINITIONS ###################################
### Follow the XDG specification
### https://gist.github.com/roalcantara/107ba66dfa3b9d023ac9329e639bc58c
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_STATE_HOME=${XDG_STATE_HOME:="$HOME/.local/state"}
export XDG_VIDEOS_DIR=${XDG_VIDEOS_DIR:="$HOME/Videos/"}
export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:="$HOME/Pictures/"}
export SCREENSHOT_DIR="${XDG_PICTURES_DIR}/Screenshots"
export SCREENRECORD_DIR="${XDG_VIDEOS_DIR}/Screencasts"

### Create the XDG_CONFIG_HOME directory specification
if [ ! -d "$XDG_CONFIG_HOME" ]; then
  mkdir -p "$XDG_CONFIG_HOME"
fi

### Create the XDG_CACHE_HOME directory specification
if [ ! -d "$XDG_CACHE_HOME" ]; then
  mkdir -p "$XDG_CACHE_HOME"
fi

### Create the XDG_DATA_HOME directory specification
if [ ! -d "$XDG_DATA_HOME" ]; then
  mkdir -p "$XDG_DATA_HOME"
fi

### Create the XDG_STATE_HOME directory specification
if [ ! -d "$XDG_STATE_HOME" ]; then
  mkdir -p "$XDG_STATE_HOME"
fi

### Create the SCREENSHOT_DIR custom directory
if [ ! -d "$SCREENSHOT_DIR" ]; then
  mkdir -p "$SCREENSHOT_DIR"
fi

### Create the SCREENRECORD_DIR custom directory
if [ ! -d "$SCREENRECORD_DIR" ]; then
  mkdir -p "$SCREENRECORD_DIR"
fi

##################################### PATH SETUP #####################################
CARGO_HOME="$XDG_DATA_HOME"/cargo
GOPATH="$XDG_DATA_HOME"/go
CUSTOM_SCRIPTS="$HOME/.local/bin/scripts"

export PATH="$HOME/.local/bin:${GOPATH}/bin:${CARGO_HOME}/bin:/var/lib/flatpak/exports/bin:/usr/local/bin:$CUSTOM_SCRIPTS:$PATH"

############################## XDG PROGRAM DEFINITIONS ##############################
### Configure programs to ensure XDG Base Directory specification is followed correctly
# https://wiki.archlinux.org/title/XDG_Base_Directory
# https://github.com/b3nj5m1n/xdg-ninja
if [[ "$(command -v cargo)" ]]; then
  export CARGO_HOME="$XDG_DATA_HOME"/cargo
fi

if [[ "$(command -v go)" ]]; then
  export GOPATH="$XDG_DATA_HOME"/go
fi

if [[ "$(command -v npm)" ]]; then
  export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
  export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
  export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
  export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
fi

if [[ "$(command -v dotnet)" ]]; then
  export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
  export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
  export OMNISHARPHOME="$XDG_CONFIG_HOME"/omnisharp
fi

if [[ "$(command -v java)" ]]; then
  export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java -Djavafx.cachedir=${XDG_CACHE_HOME}/openjfx"
fi

if [[ "$(command -v rustup)" ]]; then
  export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
fi

if [[ "$(command -v docker)" ]]; then
  export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
fi

if [[ "$(command -v node)" ]]; then
  export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
fi

if [[ "$(command -v python)" ]]; then
  export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
  export PYTHON_HISTORY="$XDG_STATE_HOME"/python_history
fi

if [[ "$(command -v parallel)" ]]; then
  export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
fi

if [[ "$(command -v mysql)" ]]; then
  export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
fi

if [[ "$(command -v w3m)" ]]; then
  export W3M_DIR="$XDG_DATA_HOME"/w3m
fi

if [[ "$(command -v wine)" ]]; then
  export WINEPREFIX="$XDG_DATA_HOME"/wine
fi

if [[ "$(command -v adb)" ]]; then
  export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
  alias adb='HOME="$XDG_DATA_HOME"/android adb'
fi

if [[ "$(command -v wget)" ]]; then
  alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
fi

if [[ "$(command -v ansible)" ]]; then
  export ANSIBLE_HOME="$XDG_DATA_HOME"/ansible
fi

export PLATFORMIO_CORE_DIR="$XDG_DATA_HOME"/platformio

if [[ -f ~/.lesshst ]]; then
  mv ~/.lesshst "$XDG_STATE_HOME"/lesshst
fi

export APP_DESKTOP_DIR="$XDG_DATA_HOME/applications"
export APP_ICON_DIR="$APP_DESKTOP_DIR/icons"
if [ ! -d "${APP_ICON_DIR}" ]; then
  mkdir -p "${APP_ICON_DIR}"
fi

export ICON_DIR="$XDG_DATA_HOME/icons/"
if [ ! -d "${ICON_DIR}" ]; then
  mkdir -p "${ICON_DIR}"
fi

export XCOMPOSEFILE="$XDG_CONFIG_HOME"/X11/xcompose

################################# USER DEFINITIONS ###################################
### Export locale settings to avoid having issues on apps that expect this value to be set
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PAGER=$(which less)
export LESS="-iRrcNK"

if [[ "$(command -v nvim)" ]]; then
  ### Ensure nvim is already installed and configured to use,
  ### due to the LSP's servers and grammar analysis provided
  export EDITOR=$(which nvim)
else
  export EDITOR=$(which vim)
fi

### Requieres python-pygments to be installed and is used to give ranger color highlight in file previews
if [[ "$(command -v pygmentize )" ]]; then
  export PYGMENTIZE_STYLE="github-dark"
fi

############################ USER DEFINITIONS FOR DE's ###############################
export THEMES_DIR="${XDG_DATA_HOME}/themes"
export CURRENT_THEME_DIR="${THEMES_DIR}/current_theme"
export XCURSOR_PATH="${XCURSOR_PATH}:$XDG_DATA_HOME/icons"
export DOT_STATE_DIR="${XDG_STATE_HOME}/dot_state"
if [ ! -d "$DOT_STATE_DIR" ]; then
  mkdir -p "$DOT_STATE_DIR"
fi
export DOT_DATA_DIR="${XDG_DATA_HOME}/dot_data"
if [ ! -d "$DOT_DATA_DIR" ]; then
  mkdir -p "$DOT_DATA_DIR"
fi

if [[ "$(command -v xdg-terminal-exec)" ]]; then
  export TERMINAL=xdg-terminal-exec
fi

### Firefox native wayland support
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
fi

### When in KDE export necessary settings for look and feel customization
### This are some 'missing' variables that should be auto set in the case of KDE
### This allowed to set the virtual keyboard to dark mode
if [[ "$DESKTOP_SESSION" == "plasma" ]]; then
  export QT_QUICK_CONTROLS_STYLE=org.kde.desktop
  export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
  export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc:"$XDG_CONFIG_HOME"/gtk-2.0/gtkrc.mine
fi

if [[ "$DESKTOP_SESSION" == "niri" ]] || [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
  export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
  export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
  export GDK_BACKEND='wayland,x11'
  export QT_QPA_PLATFORM="wayland"
  export QT_QPA_PLATFORMTHEME="qt5ct:qt6ct"
  export QT_AUTO_SCREEN_SCALE_FACTOR="1"
  export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  export QT_QUICK_CONTROLS_STYLE=org.kde.desktop
fi

###################################### DEFAULTS ######################################
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

############################### PROMPT CUSTOMIZATION ################################
if [[ "$(command -v starship)" ]]; then
  ### Set prompt to display starship config
  eval "$(starship init bash)"
fi

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
#alias -- +=pushd
#alias -- -=popd
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
  eval "$(zoxide init bash --cmd cd)"
fi

### Enable fzf integrations, needs fzf v0.48 or higher
### It enables fuzzy reverse history search
if [[ "$(command -v fzf)" ]]; then
  eval "$(fzf --bash)"
fi

if [[ "$(command -v thefuck)" ]]; then
  eval "$(thefuck --alias)"
  alias f=fuck
  export THEFUCK_EXCLUDE_RULES="fix_file"
fi

if [[ "$(command -v direnv)" ]]; then
  eval "$(direnv hook bash)"
fi

if [[ "$(command -v tldr)" ]]; then
  export TLDR_CACHE_ENABLED=1
  export TLDR_CACHE_MAX_AGE=720
fi

if [[ "$(command -v git)" && "$(command -v delta)" ]]; then
  export GIT_PAGER=delta
elif [[ "$(command -v git)" ]]; then
  export GIT_PAGER="$(which less)"
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
  alias lll='eza -1gH --color=always'
  alias llll='eza -1gHA --color=always'
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

################################### USER FUNCTIONS ##################################
### Function that calls cd, and immediately list its contents
function cs {
  cd "$@" && ls -A
}

function lazygp {
  git pull
  git add .
  git commit -m "$@"
  git push
}

################################# SETTINGS OVERRIDE #################################
### Section that overrides some plugin settings
alias mkdir='mkdir -p'

