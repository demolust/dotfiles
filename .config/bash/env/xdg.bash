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

