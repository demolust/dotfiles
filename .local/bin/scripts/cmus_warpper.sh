#!/usr/bin/env bash

song_files=()
for file in "$@"; do
  if ! [ -f "${file}" ]; then
    echo "Only files can be provided and this is not a file: ${file}, excluding it"
    continue
  fi

  if ! file --dereference --brief --mime-type -- "${file}" | grep -q audio; then
    echo "Provided file ${file} must be of an audio type, excluding it"
    continue
  fi
  song_files+=("$file")
done

uid=$(id -u)
cmus_socket="/run/user/${uid}/cmus-socket"
application="launch_tmux_cmus.sh"

if [ ! -S "${cmus_socket}" ]; then
  exec xdg-terminal-exec -e -- "${application}" &
  # Give it time to register app creation
  sleep 0.5
else
  # Pause only when playing music
  # https://github.com/cmus/cmus/issues/403
  cmus-remote -U
fi

song_file="${song_files[0]}"
# Clear the queue to start playing the selected song/songs only once
cmus-remote -C "clear -q"
# Add slected song to the queue
cmus-remote -q "${song_file}"
# Pause 0.5 sec to allow the song to be added to the queue
sleep 0.5
# Switch to the selected song
cmus-remote -n
# Start playing it
cmus-remote -p

for song_file in "${song_files[@]:1}"; do
  cmus-remote -q "${song_file}"
done
