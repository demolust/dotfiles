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

### Create some custom directory
ZSH_CACHE_DIR="$XDG_CACHE_HOME"/zsh
if [ ! -d "${ZSH_CACHE_DIR}" ]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

##################################### PATH SETUP #####################################
### PATH on zsh is controlled by a named array called path
CARGO_HOME="$XDG_DATA_HOME"/cargo
GOPATH="$XDG_DATA_HOME"/go
CUSTOM_SCRIPTS="$HOME/.local/bin/scripts"

typeset -U path PATH
path=(~/.local/bin "${GOPATH}"/bin "${CARGO_HOME}"/bin /var/lib/flatpak/exports/bin "$CUSTOM_SCRIPTS" $path)
export PATH

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
  export _JAVA_OPTIONS="-Djdk.xml.totalEntitySizeLimit=0 -Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java -Djavafx.cachedir=${XDG_CACHE_HOME}/openjfx"
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

## Enable all wayland sepecific settings per env
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
  ### Firefox native wayland support
  export MOZ_ENABLE_WAYLAND=1
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
fi
