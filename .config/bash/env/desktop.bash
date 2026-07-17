############################ USER DEFINITIONS FOR DE's ###############################
export THEMES_DIR="${XDG_DATA_HOME}/themes"
export CURRENT_THEME_DIR="${THEMES_DIR}/current_theme"
export XCURSOR_PATH="${XCURSOR_PATH}:$XDG_DATA_HOME/icons"
export CSTATE_DIR="${XDG_STATE_HOME}/cstate"
export CDATA_DIR="${XDG_DATA_HOME}/cdata"
if [ ! -d "$CSTATE_DIR" ]; then
  mkdir -p "$CSTATE_DIR"
fi
if [ ! -d "$CDATA_DIR" ]; then
  mkdir -p "$CDATA_DIR"
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

