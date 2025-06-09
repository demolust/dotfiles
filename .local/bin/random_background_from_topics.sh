#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

TOPICS=( "forest" "desert" "hills" "nasa" "universe" "planets" "landscapes" "nature" "city" "cities" "skycraper" "medieval" "castle" "castles" "sky" "software" "computers" "engineering" "transistor" "circuits" "architecture" "steampunk" "cyberpunk" "mechanical" "sculpture"  "wallpaper" "fractal" )

# Since deviantart does not support multiple keywords search with dash,
# these are removed temporary
# "computer-hardware" "electronic-hardware" "mechanical-keyboard"
# "medieval-city" "medieval-cities" "old-architecture" "modern-architecture"
# "street-photography" "street-art" 
# "traditional-art" "digital-art" "photo-manipulation" "pixel-art"

# Avoid using the same topic for both invocations
# RAND=$((RANDOM % ${#TOPICS[@]}))

min=1
max=${#TOPICS[@]}

RAND=$((RANDOM%(max-min+1)+min))
SELECTED_TOPIC=${TOPICS[$RAND]}
echo "Topic for wallpaper: ${SELECTED_TOPIC}"
echo "styli.sh -k -s ${SELECTED_TOPIC}"
styli.sh -k -s "${SELECTED_TOPIC}"

RAND=$((RANDOM%(max-min+1)+min))
SELECTED_TOPIC=${TOPICS[$RAND]}
echo "Topic for lockscreen: ${SELECTED_TOPIC}"
echo "styli.sh -K -s ${SELECTED_TOPIC}"
styli.sh -K -s "${SELECTED_TOPIC}"

