################################ COMPLETITION SETUP #################################
### Init completion
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

### Zstyles are defined via the zstyle keyword, followed by a colon-delimited list of arguments:
###   :completion:function:completer:command:argument:tag

### For autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select

### Make the commands show the breif descriptions of their arguments when cycling them with autocompletion
zstyle ':completion:*' verbose yes

### This allows completion to be able to correct any misspelled commands
zstyle ':completion:*' completer _expand _complete _correct

### Completition for elevated commands
#zstyle ':completion::complete:*' gain-privileges 1

### Case insesitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

### Add colors to completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

