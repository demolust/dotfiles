################################# HISTORY SETTINGS ##################################
### Set history saving
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=$HISTSIZE

# Share history between all sessions
setopt SHARE_HISTORY
# Write to the history file immediately, not when the shell exits
setopt INC_APPEND_HISTORY
# Do not record an entry that was just recorded again
setopt HIST_IGNORE_DUPS
# Do not write duplicate entries in the history file
setopt HIST_SAVE_NO_DUPS

# Expire duplicate entries first when trimming history
#setopt HIST_EXPIRE_DUPS_FIRST
# Delete old recorded entry (in the shell history) if new entry is a duplicate
#setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found
#setopt HIST_FIND_NO_DUPS
# Do not record an entry starting with a space
#setopt HIST_IGNORE_SPACE
# Remove superfluous blanks before record
#setopt HIST_REDUCE_BLANKS

