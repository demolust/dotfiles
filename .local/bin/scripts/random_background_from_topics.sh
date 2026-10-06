#!/usr/bin/env bash

set -Eeo pipefail
set -x

PATH="$HOME/.local/bin:$HOME/.local/bin/scripts:$HOME/bin:$PATH"
DESKTOP_SESSION_NAME=${DESKTOP_SESSION,,}
XDG_CURRENT_DESKTOP_NAME=${XDG_CURRENT_DESKTOP,,}

NATURE=(
  "forest" "desert" "hills" "landscape" "sky" "mountains"
  "ocean" "waterfall" "alpine lake" "autumn forest" "bamboo forest"
  "canyon" "coastline" "coral reef" "field of flowers" "glacier" "island"
  "jungle" "lake" "misty forest" "rainforest" "river" "sand dunes"
  "sunrise" "sunset" "volcano" "winter landscape" "wildlife" "cloudscape"
  "aerial landscape"
)

CITIES=(
  "city" "skyline" "bridge" "architecture" "skyscraper" "modern architecture" "modern city"
  "medieval" "medieval city" "castle" "cathedral" "ancient ruins" "gothic architecture"
  "old architecture" "historic building" "brutalist architecture" "lighthouse"
)

COMPUTERS=(
  "computers" "computer hardware" "retro computer"
  "server room" "data center" "software"
)

HARDWARE_AND_TECH=(
  "electronic hardware" "circuits" "circuit board" "robotics"
  "industrial design" "aircraft" "motorcycle"
)

SCI_FI_AND_GEAR=(
  "steampunk" "cyberpunk" "mechanical" "synthesizer"
)

SPACE_AND_UNIVERSE=(
  "NASA" "universe" "planets" "space art" "night sky" "moon"
  "northern lights" "astronomy" "galaxy" "nebula" "star cluster"
  "Milky Way" "satellite" "spacecraft" "rocket launch"
  "planetary surface" "Earth from space"
)

TOPICS=(
  "${NATURE[@]}"
  "${CITIES[@]}"
  "${COMPUTERS[@]}"
  "${HARDWARE_AND_TECH[@]}"
  "${SCI_FI_AND_GEAR[@]}"
  "${SPACE_AND_UNIVERSE[@]}"
)

min=1
max=${#TOPICS[@]}
RAND=$((RANDOM % (max - min + 1) + min))
SELECTED_TOPIC=${TOPICS[$RAND]}
RAND_2=$((RANDOM % (max - min + 1) + min))
SELECTED_TOPIC_2=${TOPICS[$RAND_2]}

echo "Topic for wallpaper: ${SELECTED_TOPIC}"
if [[ "$DESKTOP_SESSION_NAME" == *niri* || "$XDG_CURRENT_DESKTOP_NAME" == *niri* ]]; then
  styli.sh -n -s "${SELECTED_TOPIC}"
elif [[ "$DESKTOP_SESSION_NAME" == *hyprland* || "$XDG_CURRENT_DESKTOP_NAME" == *hyprland* ]]; then
  styli.sh -e -s "${SELECTED_TOPIC}"
elif [[ "$DESKTOP_SESSION_NAME" == *plasma* || "$DESKTOP_SESSION_NAME" == *kde* || "$XDG_CURRENT_DESKTOP_NAME" == *plasma* || "$XDG_CURRENT_DESKTOP_NAME" == *kde* ]]; then
  styli.sh -k -s "${SELECTED_TOPIC}"
else
  echo "ERR: Unsupported session (DESKTOP_SESSION=${DESKTOP_SESSION:-<unset>}, XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-<unset>})" >&2
  exit 1
fi

echo "Topic for lockscreen: ${SELECTED_TOPIC_2}"
if [[ "$DESKTOP_SESSION_NAME" == *niri* || "$XDG_CURRENT_DESKTOP_NAME" == *niri* ]]; then
  styli.sh -z -s "${SELECTED_TOPIC_2}"
elif [[ "$DESKTOP_SESSION_NAME" == *hyprland* || "$XDG_CURRENT_DESKTOP_NAME" == *hyprland* ]]; then
  styli.sh -z -s "${SELECTED_TOPIC_2}"
elif [[ "$DESKTOP_SESSION_NAME" == *plasma* || "$DESKTOP_SESSION_NAME" == *kde* || "$XDG_CURRENT_DESKTOP_NAME" == *plasma* || "$XDG_CURRENT_DESKTOP_NAME" == *kde* ]]; then
  styli.sh -K -s "${SELECTED_TOPIC_2}"
else
  echo "ERR: Unsupported session (DESKTOP_SESSION=${DESKTOP_SESSION:-<unset>}, XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-<unset>})" >&2
  exit 1
fi
