#!/usr/bin/bash
# shellcheck disable=SC2207

# Doesn't let you press Ctrl-C
function ctrl_c() {
	echo -e "\rEnter nil to drop to exit from this script"
}

trap ctrl_c SIGINT

no_of_terminals=$(tmux list-sessions 2> /dev/null | wc -l)
IFS=$'\n'

if [[ "$no_of_terminals" != "0" ]]; then
  output=($(tmux list-sessions 2>/dev/null))
  output_names=($(tmux list-sessions -F\#S 2>/dev/null))
  k=1
  echo "Choose the number of the session to attach: "
  for i in "${output[@]}"; do
    echo "$k - $i"
    ((k++))
  done
  echo
fi

echo "Create a new session by entering a name for it"
read -r input
if [[ $input == "" ]]; then
	tmux new-session
elif [[ $input == 'nil' ]]; then
	exit 1
elif [[ $input =~ ^[0-9]+$ ]] && [[ $input -le $no_of_terminals ]]; then
	terminal_name="${output_names[input - 1]}"
	tmux attach -t "$terminal_name"
else
	tmux new-session -s "$input"
fi
exit 0

