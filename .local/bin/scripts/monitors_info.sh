#!/usr/bin/env bash

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  focused_monitor="$(niri msg -j focused-output | jq -r '.name')"
  all_monitors=$(niri msg -j outputs | jq -r '.[].name')
  current_scale=$(niri msg -j focused-output | jq -r '.logical.scale')
  monitor_height=$(niri msg -j focused-output | jq -r '.modes.[]| select(.is_preferred == true) | .height')
elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
  focused_monitor="$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"
  all_monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
  current_scale=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')
  monitor_height=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .height')
fi

get_window_address (){
  local WINDOW_PATTERN="$1"

  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    WINDOW_ADDRESS=$(niri msg -j windows | jq -r --arg p "$WINDOW_PATTERN" '.[]|select((.app_id|test("\\b" + $p + "\\b";"i")) or (.title|test("\\b" + $p + "\\b";"i")))|.id' | head -n1)
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg p "$WINDOW_PATTERN" '.[]|select((.class|test("\\b" + $p + "\\b";"i")) or (.title|test("\\b" + $p + "\\b";"i")))|.address' | head -n1)
  fi
}

focus_window (){
  local WINDOW_ADDRESS="$1"

  # Give it time to register the change
  sleep 0.3

  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    niri msg action focus-window --id "$WINDOW_ADDRESS"
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"
  fi
}

get_fullscreen_selection () {
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    niri msg -j focused-output | jq -r '{scale: .logical.scale, x: .logical.x, y: .logical.y, width: (.modes[] | select(.is_preferred == true) | .width), height: (.modes[] | select(.is_preferred == true) | .height)}' | jq -r '"\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
  fi
}

get_rectangles () {
  # Output
  # It first outputs the overall resolution
  # 0,0 full_widthxfull_height
  # Then for each window it will output
  # where_it_starts (y), where_it_starts (x) widthxheight
  local active_workspace

  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    # Need to fix this logic setup, as there is no postion given by
    # niri where the window starts
    active_workspace=$(niri msg -j focused-window | jq -r '.workspace_id')

    niri msg -j focused-output | jq -r '{scale: .logical.scale, x: .logical.x, y: .logical.y, width: (.modes[] | select(.is_preferred == true) | .width), height: (.modes[] | select(.is_preferred == true) | .height)}' | jq -r '"\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"' | sort
    niri msg -j windows | jq -r --argjson ws "$active_workspace" '.[]|select(.workspace_id == $ws) | "\(.layout.pos_in_scrolling_layout[0]),\(.layout.pos_in_scrolling_layout[1]) \(.layout.window_size[0])x\(.layout.window_size[1])"' | sort

  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

    hyprctl monitors -j | jq -r --argjson ws "$active_workspace" '.[] | select(.activeWorkspace.id == $ws) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
    hyprctl clients -j | jq -r --argjson ws "$active_workspace" '.[] | select(.workspace.id == $ws) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
  fi
}

get_current_active_window (){
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    active_window=$(niri msg -j focused-window | jq -r '.app_id')
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    active_window=$(hyprctl activewindow -j | jq -r '.class')
  fi
}

focus_monitor () {
  local monitor="$1"

  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    niri msg action focus-monitor "$monitor"
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl dispatch focusmonitor "$monitor"
  fi
}

spawn_cmd () {
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    niri msg action spawn -- "$@"
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl dispatch exec -- "$@"
  fi
}

spawn_cmd_screensaver () {
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    niri msg action spawn -- "$@"
    # Give it time to register the change
    sleep 0.3
    script-launch-or-focus 'Screensaver'
    niri msg action fullscreen-window
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl dispatch exec -- "$@"
    # Give it time to register the change
    sleep 0.3
    script-launch-or-focus 'Screensaver'
  fi
}

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  default_niri_cursor_time_hide="$(grep hide-after-inactive-ms ~/.config/niri/config.kdl | awk '{print $NF}'|| "1000")"
fi

hide_cursor (){
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    echo
    sed -i "s|hide-after-inactive-ms $default_niri_cursor_time_hide|hide-after-inactive-ms 0|g" ~/.config/niri/config.kdl
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl keyword cursor:invisible true &>/dev/null
  fi
}

unhide_cursor (){
  if [[ "$DESKTOP_SESSION" == "niri" ]]; then
    echo
    sed -i "s|hide-after-inactive-ms 0|hide-after-inactive-ms $default_niri_cursor_time_hide|g" ~/.config/niri/config.kdl
  elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
    hyprctl keyword cursor:invisible false
  fi
}

