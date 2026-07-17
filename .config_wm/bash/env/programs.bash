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

