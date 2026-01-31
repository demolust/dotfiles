#!/usr/bin/env bash

if [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
  keybinds=$(hyprctl -j binds |
    jq -r '.[] | {modmask, key, keycode, description, dispatcher, arg} | "\(.modmask),\(.key)@\(.keycode),\(.description),\(.dispatcher),\(.arg)"' |
    sed -r \
      -e 's/null//' \
      -e 's,~/.local/bin/scripts/,,' \
      -e 's,uwsm app -- ,,' \
      -e 's,uwsm-app -- ,,' \
      -e 's/@0//' \
      -e 's/,@/,code:/' \
      -e 's/^0,/,/' \
      -e 's/^1,/SHIFT,/' \
      -e 's/^4,/CTRL,/' \
      -e 's/^5,/SHIFT CTRL,/' \
      -e 's/^8,/ALT,/' \
      -e 's/^9,/SHIFT ALT,/' \
      -e 's/^12,/CTRL ALT,/' \
      -e 's/^13,/SHIFT CTRL ALT,/' \
      -e 's/^64,/SUPER,/' \
      -e 's/^65,/SUPER SHIFT,/' \
      -e 's/^68,/SUPER CTRL,/' \
      -e 's/^69,/SUPER SHIFT CTRL,/' \
      -e 's/^72,/SUPER ALT,/' \
      -e 's/^73,/SUPER SHIFT ALT,/' \
      -e 's/^76,/SUPER CTRL ALT,/' \
      -e 's/^77,/SUPER SHIFT CTRL ALT,/')
elif [[ "$DESKTOP_SESSION" == "niri" ]]; then
    keybinds=$(awk '/binds {/,0' ~/.config/niri/bindings.kdl | grep -v -- '//' |
    sed -r -e 's|binds \{||' \
    -e 's|^\}||' \
    -e 's|    ||' |
    sed '/^$/d' |
    sed -e 's|^XF86|,XF86|' \
    -e 's|^Alt+|ALT,|' \
    -e 's|^Mod+Shift|SUPER SHIFT,|' \
    -e 's|^Mod+Alt|SUPER ALT,|' \
    -e 's|^Mod+Ctrl|SUPER CTRL,|' \
    -e 's|^Mod+|SUPER,|' \
    -e 's|^Print|PRINT,|' \
    -e 's|^Ctrl+Alt|CTRL ALT,|' \
    -e 's|^Ctrl+Shift|CTRL SHIFT,|' \
    -e 's|^Ctrl+|CTRL,|' \
    -e 's|,+|,|' \
    -e 's|,Print|,PRINT|' \
    -e 's|,Delete|,DELETE|' \
    -e 's|spawn|exec,|' \
    -e 's|hotkey-overlay-title=|,|' \
    -e 's|allow-when-locked=true||' \
    -e 's|repeat=false||' \
    -e 's|allow-inhibiting=false||' \
    -e 's|cooldown-ms=150||' \
    -e 's| { |,|' \
    -e 's|; }||' \
    -e 's|"||g' \
    -e 's|  ||g' \
    -e 's|, |,|g' \
    -e 's| ,|,|g' \
    -e 's|,,|,|g')
fi

