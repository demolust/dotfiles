#!/usr/bin/env bash

query_default_terminal="$(xdg-terminal-exec --print-id)"
default_terminal="${query_default_terminal/.desktop/}"

if [[ "$DESKTOP_SESSION" == "niri" ]]; then
  current_window_info=$(niri msg -j focused-window | jq -r '"\(.app_id)|\(.id)"')
  current_window=${current_window_info%|*}
  current_window_id=${current_window_info#*|}
  if [[ "$current_window" == "org.wezfurlong.wezterm" || "$current_window" =~ com.wm. ]]; then
    current_window="($default_terminal|com.wm.)"
  fi
  all_windows_id=$(niri msg -j windows | jq -r --arg cw "$current_window" '.[] | select((.app_id|test($cw;"i")))|.id')

  declare -a all_windows_id_array=( $all_windows_id )

  # Initialize index variable
  found_index=-1
  # Loop through the array elements and their indices
  for i in "${!all_windows_id_array[@]}"; do
      if [[ "${all_windows_id_array[$i]}" == "$current_window_id" ]]; then
          found_index=$i
          break # Exit the loop once the element is found
      fi
  done

  next_window_index=$((found_index + 1))
  [[ "$next_window_index" -ge "${#all_windows_id_array[@]}" ]] && next_window_index=0
  next_window="${all_windows_id_array[$next_window_index]}"
  previous_window_index=$((found_index - 1))
  #[[ "$previous_window_index" -lt -1 ]] && next_window_index=0
  previous_window="${all_windows_id_array[$previous_window_index]}"

  if [[ "$1" == "next" ]];then
    niri msg action focus-window --id "$next_window"
  elif [[ "$1" == "previous" ]]; then
    niri msg action focus-window --id "$previous_window"
  fi

elif [[ "$DESKTOP_SESSION" =~ "hyprland" ]]; then
  current_window_info=$(hyprctl activewindow -j | jq -r '"\(.class)|\(.address)"')
  current_window=${current_window_info%|*}
  current_window_id=${current_window_info#*|}
  if [[ "$current_window" == "org.wezfurlong.wezterm" || "$current_window" =~ com.wm. ]]; then
    current_window="($default_terminal|com.wm.)"
  fi
  all_windows_id=$(hyprctl clients -j | jq -r --arg cw "$current_window" '.[] | select((.class|test($cw;"i")))|.address')

  declare -a all_windows_id_array=( $all_windows_id )

  # Initialize index variable
  found_index=-1
  # Loop through the array elements and their indices
  for i in "${!all_windows_id_array[@]}"; do
      if [[ "${all_windows_id_array[$i]}" == "$current_window_id" ]]; then
          found_index=$i
          break # Exit the loop once the element is found
      fi
  done

  next_window_index=$((found_index + 1))
  [[ "$next_window_index" -ge "${#all_windows_id_array[@]}" ]] && next_window_index=0
  next_window="${all_windows_id_array[$next_window_index]}"
  previous_window_index=$((found_index - 1))
  #[[ "$previous_window_index" -lt -1 ]] && next_window_index=0
  previous_window="${all_windows_id_array[$previous_window_index]}"

  if [[ "$1" == "next" ]];then
    hyprctl dispatch focuswindow address:"$next_window"
  elif [[ "$1" == "previous" ]]; then
    hyprctl dispatch focuswindow address:"$previous_window"
  fi

fi

# Output info
#echo "current windown name: $current_window"
#echo "current window id: $current_window_id"
#echo "all windows ids:" "${all_windows_id_array[@]}"
#echo "previous window: $previous_window"
#echo "next window: $next_window"

