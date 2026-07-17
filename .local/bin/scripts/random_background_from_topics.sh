#!/usr/bin/env bash

set -Eeo pipefail
set -x

PATH="$HOME/.local/bin:$HOME/.local/bin/scripts:$HOME/bin:$PATH"
DESKTOP_SESSION_NAME=${DESKTOP_SESSION,,}
XDG_CURRENT_DESKTOP_NAME=${XDG_CURRENT_DESKTOP,,}

TOPICS=(
  "forest" "desert" "hills" "NASA" "universe" "planets" "landscape"
  "nature" "city" "skyline" "medieval" "medieval city" "castle" "sky"
  "software" "computers" "computer hardware" "mechanical keyboard"
  "engineering" "electronic hardware" "transistor" "circuits" "architecture"
  "old architecture" "modern architecture" "street photography" "street art"
  "steampunk" "cyberpunk" "mechanical" "sculpture" "traditional art"
  "digital art" "photo manipulation" "pixel art" "wallpaper" "fractal"
  "fantasy art" "space art" "night sky" "mountains" "ocean" "waterfall"
  "alpine lake" "autumn forest" "bamboo forest" "beach" "canyon" "coastline"
  "coral reef" "field of flowers" "glacier" "island" "jungle" "lake"
  "misty forest" "moon" "northern lights" "rainforest" "river" "sand dunes"
  "sunrise" "sunset" "volcano" "winter landscape" "wildlife" "cloudscape"
  "aerial landscape" "national park" "botanical garden" "Japanese garden"
  "ancient ruins" "cathedral" "library interior" "lighthouse" "bridge"
  "skyscraper" "urban night" "historic building" "art deco architecture"
  "brutalist architecture" "gothic architecture" "modern city" "village"
  "astronomy" "galaxy" "nebula" "star cluster" "solar eclipse" "Milky Way"
  "satellite" "spacecraft" "rocket launch" "planetary surface" "Earth from space"
  "microscope" "laboratory" "mathematics" "physics" "chemistry" "crystal"
  "robotics" "circuit board" "server room" "data center" "retro computer"
  "synthesizer" "vintage camera" "typewriter" "industrial design" "train"
  "aircraft" "sailing ship" "motorcycle" "bicycle" "abstract art" "geometric art"
  "oil painting" "watercolor" "illustration" "woodcut" "stained glass" "mosaic"
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
