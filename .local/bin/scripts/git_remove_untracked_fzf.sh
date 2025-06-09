#!/usr/bin/env bash

if ! [[ "$(command -v git)" && "$(command -v fzf)" && "$(command -v fzf-tmux)" && "$(command -v bat)" ]]; then
  echo "Dependencies not installed"
  exit 2
fi

if ! git rev-parse --is-inside-work-tree 1>/dev/null 2>&1;then
  printf "Error: not under a git repository\n"
  exit 1
fi

git_untracked_cmd="git ls-files --others --exclude-standard"

header_msg="Select untracked files to delete"
if [[ -n "$TMUX" ]]; then
  fzf_cmd="fzf-tmux -p 80%,80% -m --header \"$header_msg\" --border rounded --reverse --preview \"bat --color=always --style=numbers --line-range=:500 {}\""
else
  fzf_cmd="fzf -m --header \"$header_msg\" --border rounded --reverse --preview \"bat --color=always --style=numbers --line-range=:500 {}\""
fi

### Cleanup parms to not have a hypen
if [[ "$#" -gt 0 ]]; then
for param in "$@"; do
  if ! echo "$param" | grep -qP -- "-[\w]"; then
     newparams+=("$param")
  fi
done
### Overwrites the original positional params
set -- "${newparams[@]}"
fi

files_to_delete=$(eval "${git_untracked_cmd}" | eval "$fzf_cmd")
readarray -t files_to_delete_arr < <(printf '%s' "$files_to_delete")

if [[ ${#files_to_delete_arr[@]} -gt 0 ]]; then
  for file in  "${files_to_delete_arr[@]}"; do
    rm -fv "$file"
  done
fi


