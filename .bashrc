# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
CARGO_HOME="$XDG_DATA_HOME"/cargo
GOPATH="$XDG_DATA_HOME"/go
export PATH="$HOME/.local/bin:${GOPATH}/bin:${CARGO_HOME}/bin:/var/lib/flatpak/exports/bin:$PATH"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

########################################## ALIAS #############################################
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias l='ls -lA'
alias l.='ls -d .*'
alias ll='ls -l'
alias ip='ip --color=auto'
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../.."

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi

if [[ "$(command -v starship)" ]]; then
  ### Set prompt to display starship config
  eval "$(starship init bash)"
fi

