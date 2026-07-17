#!/usr/bin/env bash

set -Eeo pipefail
set -x

# shellcheck disable=SC2120,SC1090,SC2154,SC2034
# SC2120: foo references arguments, but none are ever passed.
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC2154: var is referenced but not assigned.
# SC2034: foo appears unused. Verify it or export it.

LOCAL_WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

if [ -z ${XDG_CONFIG_HOME+x} ]; then
  XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z ${XDG_CACHE_HOME+x} ]; then
  XDG_CACHE_HOME="$HOME/.cache"
fi
CACHEDIR="${XDG_CACHE_HOME}/styli.sh"
if [ ! -d "$CACHEDIR" ]; then
  mkdir -p "$CACHEDIR"
fi

WALLPAPER="$CACHEDIR/wallpaper.jpg"
WALLPAPER_EXTENSION="jpg"
QDBUS=$(command -v qdbus || command -v qdbus-qt5 || command -v qdbus-qt6) || QDBUS=""
declare -A WALLPAPER_LOCK_FDS=()

save_cmd() {
  local save_dir="$HOME/Pictures"
  local batch_id="$RANDOM"
  local image
  local name

  mkdir -p "$save_dir"
  cp "$WALLPAPER" "$save_dir/wallpaper-${batch_id}-source.${WALLPAPER_EXTENSION}"

  shopt -s nullglob
  for image in "$CACHEDIR"/cache_image_*; do
    name=$(basename "$image")
    cp "$image" "$save_dir/wallpaper-${batch_id}-${name#cache_image_}"
  done
  shopt -u nullglob
}

die() {
  printf "ERR: %s\n" "$1" >&2
  exit 1
}

on_error() {
  local status=$?
  printf 'ERR: command failed (exit %s): %s\n' "$status" "$BASH_COMMAND" >&2
  exit "$status"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command is unavailable: $1"
}

image_extension() {
  local image="$1"
  local mime_type

  require_command file
  mime_type=$(file --brief --mime-type -- "$image")
  case "$mime_type" in
  image/jpeg) printf 'jpg\n' ;;
  image/png) printf 'png\n' ;;
  image/gif) printf 'gif\n' ;;
  image/bmp) printf 'bmp\n' ;;
  image/heic) printf 'heic\n' ;;
  *) return 1 ;;
  esac
}

cache_wallpaper_source() {
  local source_file="$1"
  local extension
  local cached_file

  extension=$(image_extension "$source_file") || die "Unsupported wallpaper format: $source_file"
  cached_file="$CACHEDIR/wallpaper.${extension}"
  if [ "$source_file" != "$cached_file" ]; then
    cp "$source_file" "$cached_file"
  fi
  printf '%s\n' "$cached_file" >"$CACHEDIR/wallpaper.path"
  WALLPAPER="$cached_file"
  WALLPAPER_EXTENSION="$extension"
}

load_cached_wallpaper() {
  local cached_file

  if [ -f "$CACHEDIR/wallpaper.path" ]; then
    IFS= read -r cached_file <"$CACHEDIR/wallpaper.path"
  elif [ -f "$CACHEDIR/wallpaper.jpg" ]; then
    cached_file="$CACHEDIR/wallpaper.jpg"
  else
    return 1
  fi
  [ -n "$cached_file" ] && [ -f "$cached_file" ] || return 1
  cache_wallpaper_source "$cached_file"
}

trap on_error ERR

# TODO: Add an authenticated Unsplash API integration here when credentials and
# API registration are available. Keep its public surface to topic, width, and
# height; Commons remains the only remote source today.
unsplash() {
  local topic="${1:-${SEARCH:-landscape}}"
  local width="${2:-${WIDTH:-1920}}"
  local height="${3:-${HEIGHT:-1080}}"

  die "Unsplash support is not configured yet (topic=${topic}, size=${width}x${height})"
}

commons() {
  local query="${SEARCH:-landscape}"
  local requested_width="${WIDTH:-1920}"
  local requested_height="${HEIGHT:-1080}"
  local minimum_aspect_ratio="1.5"
  local response
  local image_url
  local image_urls_output
  local -a image_urls

  require_command curl
  require_command jq
  [[ "$requested_width" =~ ^[1-9][0-9]*$ ]] || die "Width must be a positive integer"
  [[ "$requested_height" =~ ^[1-9][0-9]*$ ]] || die "Height must be a positive integer"

  response=$(curl --fail --silent --show-error --location \
    --connect-timeout 10 --max-time 15 \
    --user-agent "styli.sh/1.0 (wallpaper downloader)" \
    --get "https://commons.wikimedia.org/w/api.php" \
    --data-urlencode "action=query" \
    --data-urlencode "format=json" \
    --data-urlencode "generator=search" \
    --data-urlencode "gsrnamespace=6" \
    --data-urlencode "gsrlimit=40" \
    --data-urlencode "gsrsearch=${query} filetype:bitmap" \
    --data-urlencode "prop=imageinfo" \
    --data-urlencode "iiprop=url|mime|size" \
    --data-urlencode "iiurlwidth=${requested_width}" \
    --data-urlencode "iiurlheight=${requested_height}") || return 1

  image_urls_output=$(jq -r \
    --argjson min_width "$requested_width" \
    --argjson min_height "$requested_height" \
    --argjson min_aspect_ratio "$minimum_aspect_ratio" '
        .query.pages[]?.imageinfo[0]
        | select(.mime == "image/jpeg" or .mime == "image/png")
        | select(.width >= $min_width and .height >= $min_height)
        | select((.width / .height) >= $min_aspect_ratio)
        | (.thumburl // .url)
    ' <<<"$response") || return 1

  while IFS= read -r image_url; do
    [ -n "$image_url" ] && image_urls+=("$image_url")
  done <<<"$image_urls_output"

  if [ "${#image_urls[@]}" -eq 0 ]; then
    return 1
  fi

  image_url=${image_urls[$((RANDOM % ${#image_urls[@]}))]}
  curl --fail --silent --show-error --location \
    --connect-timeout 10 --max-time 60 \
    --user-agent "styli.sh/1.0 (wallpaper downloader)" \
    -o "${WALLPAPER}.download" "$image_url" || {
    rm -f "${WALLPAPER}.download"
    return 1
  }
  cache_wallpaper_source "${WALLPAPER}.download"
  rm -f "${WALLPAPER}.download"
}

usage() {
  echo "Usage: styli.sh [-s | --search <string>] <Search Wikimedia Commons>
    [-h | --height <height>] <Default: 1080>
    [-w | --width <width>] <Default: 1920>
    [-b | --fehbg <feh bg opt>]
    [-c | --fehopt <feh opt>]
    [-d | --directory]
    [-k | --kde]
    [-K | --KDE]
    [-e | --hyprland]
    [-p | --hyprpaper]
    [-z | --hyprlock]
    [-n | --niri]
    [-x | --xfce]
    [-g | --gnome]
    [-m | --monitors <monitor count (nitrogen)>]
    [-N | --nitrogen]
    [-sa | --save]    <Save the source and all generated target caches to pictures directory>

    Target options can be combined; each target receives the same selected image."
  exit 2
}

type_check() {
  if [ ! -f "$WALLPAPER" ] || ! image_extension "$WALLPAPER" >/dev/null; then
    echo "MIME-Type missmatch. Downloaded file is not an image!"
    echo "Selecting an image from ${LOCAL_WALLPAPER_DIR}"
    select_random_wallpaper "${LOCAL_WALLPAPER_DIR}"
  fi

  cache_wallpaper_source "$WALLPAPER"
}

select_random_wallpaper() {
  local DIR="$1"
  local -a wallpapers

  [ -d "$DIR" ] || die "Local wallpaper directory does not exist: $DIR"
  require_command find
  require_command shuf
  mapfile -t wallpapers < <(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print)
  [ "${#wallpapers[@]}" -gt 0 ] || die "No supported images found in: $DIR"
  WALLPAPER=${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}
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
  local cache_image="$CACHEDIR/cache_image_kde.${WALLPAPER_EXTENSION}"

  [ -n "$QDBUS" ] || die "Required command is unavailable: qdbus (or qdbus-qt5/qdbus-qt6)"

  KDE_WALLPAPER_CACHEDIR="${XDG_CACHE_HOME}/kde_wall"
  if [ ! -d "$KDE_WALLPAPER_CACHEDIR" ]; then
    mkdir -p "$KDE_WALLPAPER_CACHEDIR"
  fi
  WALLPAPER_FILE="${KDE_WALLPAPER_CACHEDIR}/cache_image_kde.${WALLPAPER_EXTENSION}"
  rm -f "$CACHEDIR/cache_image_kde."*
  cp "$WALLPAPER" "$cache_image"
  cp "$cache_image" "${WALLPAPER_FILE}"
  cp "$cache_image" "$CACHEDIR/cache_image_kde_loading.${WALLPAPER_EXTENSION}"
  "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$CACHEDIR/cache_image_kde_loading.${WALLPAPER_EXTENSION}\")}"
  "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$WALLPAPER_FILE\")}"
  sleep 5 && rm -f "$CACHEDIR/cache_image_kde_loading.${WALLPAPER_EXTENSION}"
}

kde_lockscreen_cmd() {
  local cache_image="$CACHEDIR/cache_image_kde_lockscreen.${WALLPAPER_EXTENSION}"

  KDE_WALLPAPER_CACHEDIR="${XDG_CACHE_HOME}/kde_wall"
  if [ ! -d "$KDE_WALLPAPER_CACHEDIR" ]; then
    mkdir -p "$KDE_WALLPAPER_CACHEDIR"
  fi
  WALLPAPER_FILE="${KDE_WALLPAPER_CACHEDIR}/cache_image_kde_lockscreen.${WALLPAPER_EXTENSION}"
  rm -f "$CACHEDIR/cache_image_kde_lockscreen."*
  cp "$WALLPAPER" "$cache_image"
  cp "$cache_image" "${WALLPAPER_FILE}"
  kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file:$WALLPAPER_FILE"
  kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file:$WALLPAPER_FILE"
}

niri_cmd() {
  local niri_cachedir="${XDG_CACHE_HOME}/niri"
  local cache_image="$CACHEDIR/cache_image_niri.${WALLPAPER_EXTENSION}"
  local wallpaper_file

  mkdir -p "$niri_cachedir"
  wallpaper_file="${niri_cachedir}/cache_image_niri.${WALLPAPER_EXTENSION}"
  rm -f "$CACHEDIR/cache_image_niri."*
  cp "$WALLPAPER" "$cache_image"
  cp "$cache_image" "$wallpaper_file"
  set_swaybg_wallpaper "$wallpaper_file"
}

hyprland_cmd() {
  local hyprland_cachedir="${XDG_CACHE_HOME}/hyprland"
  local source_file
  local cache_image="$CACHEDIR/cache_image_hyprland.png"
  local wallpaper_file
  local mimetype

  mkdir -p "$hyprland_cachedir"
  source_file="${hyprland_cachedir}/cache_image_hyprland_source.${WALLPAPER_EXTENSION}"
  wallpaper_file="${hyprland_cachedir}/cache_image_hyprland.png"
  cp "$WALLPAPER" "$source_file"

  mimetype=$(file --dereference --brief --mime-type -- "$source_file")
  if [[ "$mimetype" == *png ]]; then
    cp "$source_file" "$cache_image"
  else
    magick convert -- "$source_file" "$cache_image"
  fi
  cp "$cache_image" "$wallpaper_file"

  set_swaybg_wallpaper "$wallpaper_file"
}

hyprpaper_cmd() {
  local hyprpaper_cachedir="${XDG_CACHE_HOME}/hyprpaper"
  local cache_image="$CACHEDIR/cache_image_hyprpaper.png"
  local wallpaper_file="${hyprpaper_cachedir}/cache_image_hyprpaper.png"
  local mimetype

  mkdir -p "$hyprpaper_cachedir"
  mimetype=$(file --dereference --brief --mime-type -- "$WALLPAPER")
  if [[ "$mimetype" == *png ]]; then
    cp "$WALLPAPER" "$cache_image"
  else
    require_command magick
    magick convert -- "$WALLPAPER" "$cache_image"
  fi
  cp "$cache_image" "$wallpaper_file"

  require_command hyprctl
  # TODO: Test this against the installed Hyprpaper daemon and validate its
  # IPC/configuration behavior before making --hyprpaper the default target.
  hyprctl hyprpaper wallpaper ", $wallpaper_file, cover"
}

set_swaybg_wallpaper() {
  local wallpaper_file="$1"
  local swaybg_pid

  if [ ! -f "$wallpaper_file" ]; then
    die "$wallpaper_file doesn't exist, can't set it"
  fi

  pkill swaybg 2>/dev/null || true
  swaybg -m fill -i "$wallpaper_file" &
  swaybg_pid=$!
  sleep 0.2
  if ! kill -0 "$swaybg_pid" 2>/dev/null; then
    wait "$swaybg_pid" 2>/dev/null || true
    die "swaybg exited immediately; wallpaper was not applied"
  fi
}

acquire_wallpaper_lock() {
  local lock_name="$1"
  local lock_dir
  local lock_file
  local lock_fd

  if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    lock_dir="$XDG_RUNTIME_DIR/styli.sh"
    mkdir -p "$lock_dir"
  else
    lock_dir="$CACHEDIR"
  fi
  lock_file="$lock_dir/wallpaper-${lock_name}.lock"

  exec {lock_fd}>"$lock_file"
  if ! flock -w 300 "$lock_fd"; then
    exec {lock_fd}>&-
    die "Timed out waiting for the ${lock_name} wallpaper lock"
  fi
  WALLPAPER_LOCK_FDS["$lock_name"]=$lock_fd
}

release_wallpaper_lock() {
  local lock_name="$1"
  local lock_fd="${WALLPAPER_LOCK_FDS[$lock_name]:-}"

  [ -n "$lock_fd" ] || return 0
  flock -u "$lock_fd"
  exec {lock_fd}>&-
  unset "WALLPAPER_LOCK_FDS[$lock_name]"
}

hyprlock_cmd() {
  local cache_image="$CACHEDIR/cache_image_hyprlock.${WALLPAPER_EXTENSION}"
  local hyprlock_cachedir="${XDG_CACHE_HOME}/hyprlock"
  local wallpaper_file="${hyprlock_cachedir}/cache_image_hyprlock_source.${WALLPAPER_EXTENSION}"

  mkdir -p "$hyprlock_cachedir"
  rm -f "$CACHEDIR/cache_image_hyprlock."*
  cp "$WALLPAPER" "$cache_image"
  cp "$cache_image" "$wallpaper_file"
  set_hyprlock_wallpaper "$wallpaper_file"
}

set_hyprlock_wallpaper() {
  local source_file="$1"
  local hyprlock_cachedir="${XDG_CACHE_HOME}/hyprlock"
  local wallpaper_file="${hyprlock_cachedir}/cache_image_hyprlock.png"
  local config_file="${XDG_CONFIG_HOME}/hypr/hyprlock.conf"
  local mimetype

  mimetype=$(file --dereference --brief --mime-type -- "$source_file")
  if [[ "$mimetype" == *png ]]; then
    cp "$source_file" "$wallpaper_file"
  else
    magick convert -- "$source_file" "$wallpaper_file"
  fi

  if [ ! -f "$wallpaper_file" ]; then
    die "$wallpaper_file doesn't exist, can't set it"
  fi
  if [ ! -f "$config_file" ]; then
    die "$config_file doesn't exist, can't set the Hyprlock wallpaper"
  fi

  sed -i "s|path = .*|path = $wallpaper_file|g" "$config_file"
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
HYPRPAPER=false
HYPRLOCK=false
XFCE=false
GNOME=false
NITROGEN=false
SWAY=false
MONITORS=1
# SC2034
if ! PARSED_ARGUMENTS=$(getopt -a -n "$0" -o h:w:s:b:c:d:m:kKnNxgypez --long search:,height:,width:,fehbg:,fehopt:,directory:,monitors:,kde,KDE,niri,nitrogen,hyprland,hyprpaper,hyprlock,xfce,gnome,sway,save -- "$@"); then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"

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
  --save)
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
  -p | --hyprpaper)
    HYPRPAPER=true
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

acquire_wallpaper_lock source
if [ "$KDE" = true ]; then
  acquire_wallpaper_lock kde
fi
if [ "$KDE_LOCK" = true ]; then
  acquire_wallpaper_lock kde_lockscreen
fi
if [ "$NIRI" = true ]; then
  acquire_wallpaper_lock niri
fi
if [ "$HYPRLAND" = true ]; then
  acquire_wallpaper_lock hyprland
fi
if [ "$HYPRPAPER" = true ]; then
  acquire_wallpaper_lock hyprpaper
fi
if [ "$HYPRLOCK" = true ]; then
  acquire_wallpaper_lock hyprlock
fi

if [ -n "${SAVE:-}" ]; then
  load_cached_wallpaper || die "No cached wallpaper is available to save"
  save_cmd
  release_wallpaper_lock source
  exit 0
elif [ -n "${DIR:-}" ]; then
  select_random_wallpaper "$DIR"
else
  if ! commons; then
    echo "Wikimedia Commons did not return a usable image; selecting a local wallpaper instead."
    select_random_wallpaper "${LOCAL_WALLPAPER_DIR}"
  fi
fi

type_check

if [ "$KDE" = true ]; then
  kde_cmd
fi
if [ "$KDE_LOCK" = true ]; then
  kde_lockscreen_cmd
fi
if [ "$NIRI" = true ]; then
  niri_cmd
fi
if [ "$HYPRLAND" = true ]; then
  hyprland_cmd
fi
if [ "$HYPRPAPER" = true ]; then
  hyprpaper_cmd
fi
if [ "$HYPRLOCK" = true ]; then
  hyprlock_cmd
fi
if [ "$XFCE" = true ]; then
  xfce_cmd
fi
if [ "$GNOME" = true ]; then
  gnome_cmd
fi
if [ "$NITROGEN" = true ]; then
  nitrogen_cmd
fi
if [ "$SWAY" = true ]; then
  sway_cmd
fi
if [ "$KDE" != true ] && [ "$KDE_LOCK" != true ] && [ "$NIRI" != true ] && [ "$HYPRLAND" != true ] && [ "$HYPRPAPER" != true ] && [ "$HYPRLOCK" != true ] && [ "$XFCE" != true ] && [ "$GNOME" != true ] && [ "$NITROGEN" != true ] && [ "$SWAY" != true ]; then
  echo "Finished processing"
fi

release_wallpaper_lock hyprlock
release_wallpaper_lock hyprpaper
release_wallpaper_lock hyprland
release_wallpaper_lock niri
release_wallpaper_lock kde_lockscreen
release_wallpaper_lock kde
release_wallpaper_lock source
