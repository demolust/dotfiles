#!/usr/bin/env bash

# Use XDG_CURRENT_DESKTOP as it is more standard for Wayland
SESSION="${XDG_CURRENT_DESKTOP,,}" # Convert to lowercase for easier matching

case "$1" in
    on)
        if [[ "$SESSION" == *"niri"* ]]; then
            niri msg action power-on-monitors
        elif [[ "$SESSION" == *"hyprland"* ]]; then
            hyprctl dispatch dpms on
        fi
        # Optional: Restore brightness for both
        brightnessctl -r
        ;;
    off)
        if [[ "$SESSION" == *"niri"* ]]; then
            niri msg action power-off-monitors
        elif [[ "$SESSION" == *"hyprland"* ]]; then
            hyprctl dispatch dpms off
        fi
        ;;
esac
