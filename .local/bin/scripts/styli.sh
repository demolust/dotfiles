#!/usr/bin/env bash

set -x

# shellcheck disable=SC2120,SC1090,SC2154,SC2034
# SC2120: foo references arguments, but none are ever passed.
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC2154: var is referenced but not assigned.
# SC2034: foo appears unused. Verify it or export it.

LINK="https://source.unsplash.com/random/"
LOCAL_WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

if [ -z ${XDG_CONFIG_HOME+x} ]; then
    XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z ${XDG_CACHE_HOME+x} ]; then
    XDG_CACHE_HOME="$HOME/.cache"
fi
CONFDIR="${XDG_CONFIG_HOME}/styli.sh"
if [ ! -d "$CONFDIR" ]; then
    mkdir -p "$CONFDIR"
fi
CACHEDIR="${XDG_CACHE_HOME}/styli.sh"
if [ ! -d "$CACHEDIR" ]; then
    mkdir -p "$CACHEDIR"
fi

WALLPAPER="$CACHEDIR/wallpaper.jpg"
QDBUS=$(command -v qdbus || command -v qdbus-qt5 || command -v qdbus-qt6)

save_cmd() {
    cp "$WALLPAPER" "$HOME/Pictures/wallpaper$RANDOM.jpg"
}

die() {
    printf "ERR: %s\n" "$1" >&2
    exit 1
}

reddit() {
    USERAGENT="thevinter"
    TIMEOUT=60

    SORT="$2"
    TOP_TIME="$3"
    if [ -z "$SORT" ]; then
        SORT="hot"
    fi

    if [ -z "$TOP_TIME" ]; then
        TOP_TIME=""
    fi

    if [ -n "$1" ]; then
        SUB="$1"
    else
        if [ ! -f "$CONFDIR/subreddits" ]; then
            echo "Please install the subreddits file in $CONFDIR"
            exit 2
        fi
        mapfile -t SUBREDDITS <"$CONFDIR/subreddits"
        a=${#SUBREDDITS[@]}
        b=$((RANDOM % a))
        SUB=${SUBREDDITS[$b]}
        SUB="$(echo -e "$SUB" | tr -d '[:space:]')"
    fi

    URL="https://www.reddit.com/r/$SUB/$SORT/.json?raw_json=1&t=$TOP_TIME"
    CONTENT=$(wget -T $TIMEOUT -U "$USERAGENT" -q -O - "$URL")
    mapfile -t URLS <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')"
    wait # prevent spawning too many processes
    SIZE=${#URLS[@]}
    if [ "$SIZE" -eq 0 ]; then
        echo The current subreddit is not valid.
        exit 1
    fi
    IDX=$((RANDOM % SIZE))
    # TARGET_NAME, TARGET_ID, EXT and NEWNAME are not used
    # mapfile -t IDS <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')"
    # mapfile -t NAMES <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')"
    TARGET_URL=${URLS[$IDX]}
    # TARGET_NAME=${NAMES[$IDX]}
    # TARGET_ID=${IDS[$IDX]}
    # EXT=$(echo -n "${TARGET_URL##*.}" | cut -d '?' -f 1)
    # NEWNAME=$(echo "$TARGET_NAME" | sed "s/^\///;s/\// /g")_"$SUBREDDIT"_$TARGET_ID.$EXT
    wget -T $TIMEOUT -U "$USERAGENT" --no-check-certificate -q -P down -O "$WALLPAPER" "$TARGET_URL" &>/dev/null
}

unsplash() {
    local SEARCH="${SEARCH// /+}"
    if [ -n "$HEIGHT" ] || [ -n "$WIDTH" ]; then
        LINK="${LINK}${WIDTH}x${HEIGHT}" # dont remove {} from variables
    else
        LINK="${LINK}1920x1080"
    fi

    if [ -n "$SEARCH" ]; then
        LINK="${LINK}/?${SEARCH}"
    fi

    wget -q -O "$WALLPAPER" "$LINK"
}

deviantart() {

    if [ -z "$SEARCH" ]; then
    TOPICS=( "forest" "desert" "hills" "nasa" "universe" "planets" "passages" "landscapes" "nature" "city" "cities" "skycrapper" "medieval" "medieval-city" "medieval-cities" "castle" "castles" "clouds" "software" "computers" "computer-hardware" "mechanical-keyboard" "engineering" "electronic-hardware" "transistor" "circuits" "architecture" "old-architecture" "modern-architecture" "steampunk" "cyberpunk" "mechanical" "anthro" "drawings-and-paintings" "stock-images" "sculpture" "traditional-art" "street-photography" "street-art" "pixel-art" "wallpaper" "digital-art" "photo-manipulation" "fractal" "fantasy" "3d" "drawings-and-paintings" "game-art" )
      RAND=$((RANDOM % ${#TOPICS[@]}))
      SEARCH="${TOPICS[$RAND]}"
    fi

    CLIENT_ID=16531
    CLIENT_SECRET=68c00f3d0ceab95b0fac638b33a3368e
    PAYLOAD="grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
    ACCESS_TOKEN=$(curl --silent -d $PAYLOAD https://www.deviantart.com/oauth2/token | jq -r '.access_token')
    URL="https://www.deviantart.com/api/v1/oauth2/browse/topic?limit=24&topic=${SEARCH}"
    CONTENT=$(curl --silent -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Accept: application/json" -H "Content-Type: application/json" "$URL")
    mapfile -t URLS <<<"$(echo -n "$CONTENT" | jq -r '.results[].content.src')"
    SIZE=${#URLS[@]}
    IDX=$((RANDOM % SIZE))
    TARGET_URL=${URLS[$IDX]}
    wget --no-check-certificate -q -P down -O "$WALLPAPER" "$TARGET_URL" &>/dev/null
}

usage() {
    echo "Usage: styli.sh [-s | --search <string>]
    [-h | --height <height>]
    [-w | --width <width>]
    [-b | --fehbg <feh bg opt>]
    [-c | --fehopt <feh opt>]
    [-a | --artist <deviant artist>]
    [-r | --subreddit <subreddit>]
    [-l | --link <source>]
    [-d | --directory]
    [-k | --kde]
    [-K | --KDE]
    [-e | --hyprland]
    [-z | --hyprlock]
    [-n | --niri]
    [-x | --xfce]
    [-g | --gnome]
    [-m | --monitors <monitor count (nitrogen)>]
    [-N | --nitrogen]
    [-sa | --save]    <Save current image to pictures directory>"
    exit 2
}

type_check() {
    MIME_TYPES=("image/bmp" "image/jpeg" "image/gif" "image/png" "image/heic")
    ISTYPE=false

    for REQUIREDTYPE in "${MIME_TYPES[@]}"; do
        IMAGETYPE=$(file --mime-type "$WALLPAPER" | awk '{print $2}')
        if [ "$REQUIREDTYPE" = "$IMAGETYPE" ]; then
            ISTYPE=true
            break
        fi
    done

    if [ $ISTYPE = false ]; then
        echo "MIME-Type missmatch. Downloaded file is not an image!"
        echo "Selecting an image from ${LOCAL_WALLPAPER_DIR}"
        select_random_wallpaper "${LOCAL_WALLPAPER_DIR}"
    fi
}

select_random_wallpaper() {
    local DIR="$1"
    WALLPAPER=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" -o -iname "*.gif" \) -print | shuf -n 1)
}

sway_cmd() {
    if [ -n "$BGTYPE" ]; then
        if [ "$BGTYPE" == 'bg-center' ]; then
            MODE="center"
        fi
        if [ "$BGTYPE" == 'bg-fill' ]; then
            MODE="fill"
        fi
        if [ "$BGTYPE" == 'bg-max' ]; then
            MODE="fit"
        fi
        if [ "$BGTYPE" == 'bg-scale' ]; then
            MODE="stretch"
        fi
        if [ "$BGTYPE" == 'bg-tile' ]; then
            MODE="tile"
        fi
    else
        MODE="stretch"
    fi
    swaymsg output "*" bg "$WALLPAPER" "$MODE"

}

nitrogen_cmd() {
    for ((MONITOR = 0; monitor < "$MONITORS"; monitor++)); do
        local NITROGEN_ARR=(nitrogen --save --head="$MONITOR")

        if [ -n "$BGTYPE" ]; then
            if [ "$BGTYPE" == 'bg-center' ]; then
                NITROGEN_ARR+=(--set-centered)
            fi
            if [ "$BGTYPE" == 'bg-fill' ]; then
                NITROGEN_ARR+=(--set-zoom-fill)
            fi
            if [ "$BGTYPE" == 'bg-max' ]; then
                NITROGEN_ARR+=(--set-zoom)
            fi
            if [ "$BGTYPE" == 'bg-scale' ]; then
                NITROGEN_ARR+=(--set-scaled)
            fi
            if [ "$BGTYPE" == 'bg-tile' ]; then
                NITROGEN_ARR+=(--set-tiled)
            fi
        else
            NITROGEN_ARR+=(--set-scaled)
        fi

        if [ -n "$CUSTOM" ]; then
            NITROGEN_ARR+=("$CUSTOM")
        fi

        NITROGEN_ARR+=("$WALLPAPER")

        "${NITROGEN_ARR[@]}"
    done
}

kde_cmd() {
    KDE_WALLPAPER_CACHEDIR="${XDG_CACHE_HOME}/kde_wall"
    if [ ! -d "$KDE_WALLPAPER_CACHEDIR" ]; then
      mkdir -p "$KDE_WALLPAPER_CACHEDIR"
    fi
    WALLPAPER_FILE="${KDE_WALLPAPER_CACHEDIR}/wall.jpg"
    cp "$WALLPAPER" "${WALLPAPER_FILE}"
    cp "$WALLPAPER" "$CACHEDIR/tmp.jpg"
    $QDBUS org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$CACHEDIR/tmp.jpg\")}"
    $QDBUS org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$WALLPAPER_FILE\")}"
    sleep 5 && rm -f "$CACHEDIR/tmp.jpg"
}

kde_lockscreen_cmd() {
    KDE_WALLPAPER_CACHEDIR="${XDG_CACHE_HOME}/kde_wall"
    if [ ! -d "$KDE_WALLPAPER_CACHEDIR" ]; then
      mkdir -p "$KDE_WALLPAPER_CACHEDIR"
    fi
    WALLPAPER_FILE="${KDE_WALLPAPER_CACHEDIR}/lock.jpg"
    cp "$WALLPAPER" "${WALLPAPER_FILE}"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file:$WALLPAPER_FILE"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file:$WALLPAPER_FILE"
}

niri_cmd() {
  NIRI_CACHEDIR="${XDG_CACHE_HOME}/niri"
  if [ ! -d "$NIRI_CACHEDIR" ]; then
    mkdir -p "$NIRI_CACHEDIR"
  fi
  WALLPAPER_FILE="${NIRI_CACHEDIR}/tmp.jpg"
  cp "$WALLPAPER" "${WALLPAPER_FILE}"
  set_niri_wallpaper.sh
}

hyprland_cmd() {
  HYPRLAND_CACHEDIR="${XDG_CACHE_HOME}/hyprland"
  if [ ! -d "$HYPRLAND_CACHEDIR" ]; then
    mkdir -p "$HYPRLAND_CACHEDIR"
  fi
  WALLPAPER_FILE="${HYPRLAND_CACHEDIR}/tmp.jpg"
  cp "$WALLPAPER" "${WALLPAPER_FILE}"
  set_hyprland_wallpaper.sh
}

hyprlock_cmd() {
  HYPRLOCK_CACHEDIR="${XDG_CACHE_HOME}/hyprlock"
  if [ ! -d "$HYPRLOCK_CACHEDIR" ]; then
    mkdir -p "$HYPRLOCK_CACHEDIR"
  fi
  WALLPAPER_FILE="${HYPRLOCK_CACHEDIR}/hyprlock.jpg"
  cp "$WALLPAPER" "${WALLPAPER_FILE}"
  set_hyprlock_wallpaper.sh
}

xfce_cmd() {
    ## CONNECTEDOUTPUTS ACTIVEOUTPUT and CONNECTED are not used
    # CONNECTEDOUTPUTS=$(xrandr | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    # ACTIVEOUTPUT=$(xrandr | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    # CONNECTED=$(echo "$CONNECTEDOUTPUTS" | wc -w)

    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -n -t string -s ~/Pictures/1.jpeg
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorLVDS1/workspace0/last-image -n -t string -s ~/Pictures/1.jpeg

    for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep -E -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
        xfconf-query -c xfce4-desktop -p "$i" -n -t string -s "$WALLPAPER"
        xfconf-query -c xfce4-desktop -p "$i" -s "$WALLPAPER"
    done
}

gnome_cmd() {
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
}

feh_cmd() {
    local FEH
    FEH=(feh)
    if [ -n "$BGTYPE" ]; then
        if [ "$BGTYPE" == 'bg-center' ]; then
            FEH+=(--bg-center)
        fi
        if [ "$BGTYPE" == 'bg-fill' ]; then
            FEH+=(--bg-fill)
        fi
        if [ "$BGTYPE" == 'bg-max' ]; then
            FEH+=(--bg-max)
        fi
        if [ "$BGTYPE" == 'bg-scale' ]; then
            FEH+=(--bg-scale)
        fi
        if [ "$BGTYPE" == 'bg-tile' ]; then
            FEH+=(--bg-tile)
        fi
    else
        FEH+=(--bg-scale)
    fi

    if [ -n "$CUSTOM" ]; then
        FEH+=("$CUSTOM")
    fi

    FEH+=("$WALLPAPER")

    "${FEH[@]}"
}

KDE=false
KDE_LOCK=false
NIRI=false
HYPRLAND=false
HYPRLOCK=flase
XFCE=false
GNOME=false
NITROGEN=false
SWAY=false
MONITORS=1
# SC2034
PARSED_ARGUMENTS=$(getopt -a -n "$0" -o h:w:s:l:b:r:a:c:d:m:kKnNxgyez:sa --long search:,height:,width:,fehbg:,fehopt:,artist:,subreddit:,directory:,monitors:,kde,KDE,niri,nitrogen,hyprland,hyprlock,xfce,gnome,sway,save -- "$@")

VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

while :; do
    case "${1}" in
    -b | --fehbg)
        BGTYPE=${2}
        shift 2
        ;;
    -s | --search)
        SEARCH=${2}
        shift 2
        ;;
    -sa | --save)
        SAVE=true
        shift
        ;;
    -h | --height)
        HEIGHT=${2}
        shift 2
        ;;
    -w | --width)
        WIDTH=${2}
        shift 2
        ;;
    -l | --link)
        LINK=${2}
        shift 2
        ;;
    -r | --subreddit)
        SUB=${2}
        shift 2
        ;;
    -a | --artist)
        ARTIST=${2}
        shift 2
        ;;
    -c | --fehopt)
        CUSTOM=${2}
        shift 2
        ;;
    -m | --monitors)
        MONITORS=${2}
        shift 2
        ;;
    -N | --nitrogen)
        NITROGEN=true
        shift
        ;;
    -d | --directory)
        DIR=${2}
        shift 2
        ;;
    -k | --kde)
        KDE=true
        shift
        ;;
     -K | --KDE)
        KDE_LOCK=true
        shift
        ;;
    -n | --niri)
        NIRI=true
        shift
        ;;
    -x | --xfce)
        XFCE=true
        shift
        ;;
    -g | --gnome)
        GNOME=true
        shift
        ;;
    -y | --sway)
        SWAY=true
        shift
        ;;
    -e | --hyprland)
        HYPRLAND=true
        shift
        ;;
    -z | --hyprlock)
        HYPRLOCK=true
        shift
        ;;
    -- | '')
        shift
        break
        ;;
    *)
        echo "Unexpected option: $1 - this should not happen."
        usage
        ;;
    esac
done

if [ -n "$DIR" ]; then
  select_random_wallpaper "$DIR"
elif [ "$LINK" = "reddit" ] || [ -n "$SUB" ]; then
  reddit "$SUB"
elif [ "$LINK" = "deviantart" ] || [ -n "$ARTIST" ]; then
  deviantart "$ARTIST"
elif [ -n "$SAVE" ]; then
  save_cmd
else
  #unsplash
  #deviantart
  select_random_wallpaper "${LOCAL_WALLPAPER_DIR}"
fi

type_check

if [ "$KDE" = true ]; then
    kde_cmd
elif [ "$KDE_LOCK" = true ]; then
    kde_lockscreen_cmd
elif [ "$NIRI" = true ]; then
    niri_cmd
elif [ "$HYPRLAND" = true ]; then
    hyprland_cmd
elif [ "$HYPRLOCK" = true ]; then
    hyprlock_cmd
elif [ "$XFCE" = true ]; then
    xfce_cmd
elif [ "$GNOME" = true ]; then
    gnome_cmd
elif [ "$NITROGEN" = true ]; then
    nitrogen_cmd
elif [ "$SWAY" = true ]; then
    sway_cmd
else
    echo "Finished processing"
fi
