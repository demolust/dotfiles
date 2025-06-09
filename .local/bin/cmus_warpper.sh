#!/bin/bash

for file in "$@"; do
  [ ! -f "${file}" ] && echo "Only files can be provided and this is not a file: ${file}" && exit 1
  #if ! xdg-mime query filetype "${file}" | grep -qi audio; then
  if ! file "${file}" | grep -qi audio; then
    echo "Provided file ${file} must be of an audio type"
    exit 2
  fi
done

song_file="$1"
uid=$(id -u)
cmus_socket="/run/user/${uid}/cmus-socket"
application="launch_tmux_cmus.sh"
current_date=$(date +'%Y-%m-%d_%R:%S')

if [ ! -S "${cmus_socket}" ]; then
  nohup "${CTERM}" -e "${application}" > ~/.local/logs/"${application}"_"${current_date}".log 2>&1 &
  # Sleep 0.5 sec to allow all the socket control to not clash
  sleep 0.5
else
  # Pause only when playing music
  # https://github.com/cmus/cmus/issues/403 
  cmus-remote -U
  # Another Workaround is to use cmus-remote -Q | grep playing, then if so use cmus-remote -u
  # So far there is no need to sleep 0.5-1 sec here
fi

# Clear the queue to start playing the selected song/songs only once
cmus-remote -C "clear -q"
# Add slected song to the queue
cmus-remote -q "${song_file}"
# Pause 0.5 sec to allow the song to be added to the queue
sleep 0.5
# Switch to the selected song
cmus-remote -n
# Start playing it
if cmus-remote -Q | grep -q "status stopped"; then
  sleep 0.5
  cmus-remote -p
fi

# Add to the queue the remaining files
# Since the first one is already begin played shift it
shift 1
index_file=1
number_of_files=$#
while [ $index_file -le $number_of_files ]; do
  new_song_file="$1"
  cmus-remote -q "${new_song_file}"
  index_file=$((index_file + 1))
  shift 1
done

