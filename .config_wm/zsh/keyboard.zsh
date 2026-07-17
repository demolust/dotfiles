#################################### CUSTOM KEYS ####################################
### To list all commands `zle -al` that can be mapped to a key binding
### To view all current applied binkeys `bindkey -L`

### Set termianl to act as an emacs
bindkey -e

### FROM ARCH WIKI (1)
# https://wiki.archlinux.org/title/zsh#Key_bindings

# create a zkbd compatible hash;  to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

### For xterm-compatible terminals extended key-definitions
key[CtrlLft]="${terminfo[kLFT5]}"
key[CtrlRft]="${terminfo[kRIT5]}"
key[CtrlDel]="${terminfo[kDC5]}"
key[CtrlUp]="${terminfo[kUP5]}"
key[CtrlDwn]="${terminfo[kDN5]}"

# This combinations may need to be tested
key[ShftCtrlLft]="${terminfo[kLFT6]}"
key[ShftCtrlRft]="${terminfo[kRIT6]}"

### This defeinitons can be found over
# https://wiki.archlinux.org/title/zsh#Shift,_Alt,_Ctrl_and_Meta_modifiers
# https://man.archlinux.org/man/user_caps.5#Extended_key-definitions
# https://stackoverflow.com/questions/31379824/how-to-get-control-characters-for-ctrlleft-from-terminfo-in-zsh

# setup key accordingly
### Set `Home` to got beginning to the of line
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
### Set `End` to got to the end of line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
### Set
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
### Set `Backspace` to normal behavior, which is delete backward
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
### Set `Delete` to remove a single char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
### Set Arrow keys
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
### Set `PageUp` to get to the begining of history
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
### Set `PageDown` to get to the ending of history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
### Set `Shift+Tab` to reverse completion
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete


if [[ -n $TERM && $TERM == *"xterm"* ]]; then
  ### For xterm-compatible terminals extended key-definitions
  ### Set `Ctrl + LeftArrow` to move backwards between words
  [[ -n "${key[CtrlLft]}" ]] && bindkey -- "${key[CtrlLft]}"  backward-word
  ### Set `Ctrl + RightArrow` to move foward between words
  [[ -n "${key[CtrlRft]}" ]] && bindkey -- "${key[CtrlRft]}"  forward-word
  ### Set `Ctrl + Delete` to remove a word
  [[ -n "${key[CtrlDel]}" ]] && bindkey -- "${key[CtrlDel]}"  delete-word

  ### Set history search backward & foward using Ctrl + Up/Down Arrowkeys
  #this is based from the cursor position and what is written until that point
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search

  ### Set `Ctrl + UpArrow` to search upwards for similar witten command
  [[ -n "${key[CtrlUp]}"  ]] && bindkey -- "${key[CtrlUp]}"  up-line-or-beginning-search
  ### Set `Ctrl + DownArrow` to search downwards for similar witten command
  [[ -n "${key[CtrlDwn]}" ]] && bindkey -- "${key[CtrlDwn]}" down-line-or-beginning-search

fi

# Finally, make sure the terminal is in application mode, when zle is active
# Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

### MANUAL CUSTOM KEYS SETUP
### Overwrite `Ctrl + p` to behave like `Ctrl + Shift + UpArrow`
bindkey '^p' up-line-or-beginning-search
### Overwrite `Ctrl + n` to behave like `Ctrl + Shift + DownArrow`
bindkey '^n'  down-line-or-beginning-search
### To find which char combinations represents a key or key combination first use `Ctrl + v` or the `read` command, then input the desired key or key combinations
### Set `Ctrl-u` to kill from current cursor position to the begining of the line '\C-u'
bindkey "^U" backward-kill-line
### Set `Ctrl-k` to kill from current cursor position to the ending of the line '\C-k'
bindkey "^K" kill-line
# `Ctrl-x, Ctrl-e` - Edit the current command line in $EDITOR '\C-x\C-e'
autoload -U edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
# `Ctrl + Backspace` - Deletes one word backwards, from the current cursor location
bindkey "^H" backward-kill-word

## Make EMACS mode more similar to VIM Normal Mode
# `Ctrl + ^` Moves to the beginning-of the line (Similar as VIM Normal Mode)
bindkey "^^" beginning-of-line
# `Alt + $` Moves forward to the end of the end (Similar as VIM Normal Mode)
bindkey "^[$" end-of-line

### WELL KONWN STANDARD SHORTCUTS
### Alt can be substituted with Esc
# `Ctrl + a` ---> Moves the cursor to the beginning of the line
# `Ctrl + e` ---> Moves the cursor to the end of the line
# `Ctrl + w` ---> Deletes the one word backwards from the cursor location
# `Ctrl + k` ---> Kills (or deletes) until the end of the line
# `Ctrl + r` ---> Incremental search backwards
# `Ctrl + s` ---> Incremental search forwards (automatically enables NO_FLOW_CONTROL option)
# `Ctrl + d` ---> Deletes a character (moves forward) / lists completions / logs out
# `Ctrl + f` ---> Moves the cursor forward one character
# `Ctrl + y` ---> Yanks the last killed word
# `Ctrl + t` ---> Transposes/Swaps two characters
# `Alt  + t` ---> Transposes/Swaps two words
# `Alt  + d` ---> Deletes one word on the right of the cursor
# `Alt  + b` ---> Moves the cursor backwards one word
# `Alt  + f` ---> Moves the cursor forward one word
# `Alt  + u` ---> Capitalize word to the right
# `Alt  + l` ---> Uncapitalize word to the right
# `Alt  + y` ---> Switches the last yanked word
# `Alt  + a` ---> Enter a new line, execute the command and reposition everything
# `Alt  + Backspace` ---> Deletes one word backwards, from the cursor location

### SOME OTHER DEFINITIONS
# `Alt  + p` ---> Behaves like `Ctrl + p`
# `Alt  + n` ---> Behaves like `Ctrl + n`

### REPLACED FROM THE STANDARD DEFINITION
# `Ctrl + u` ---> Deletes the whole line
# `Ctrl + b` ---> Moves the cursor backwards one character
