### Add plugins via zinit
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  ### Enables new additional completion definitions for zsh
  zinit light zsh-users/zsh-completions
  ### Provides syntax highlighting of commands for the shell zsh
  zinit light zsh-users/zsh-syntax-highlighting
  ### Enables Fish-like fast/unobtrusive autosuggestions for zsh, first clone repo as
  zinit light zsh-users/zsh-autosuggestions
  ### `fzf-tab` enables completion selection menu with fzf
  zinit light Aloxaf/fzf-tab
  ### `fzf-git` enables git completion selection menu with fzf
  zinit light junegunn/fzf-git.sh

  ### `forgit` enables to use git interactively with fzf
  ### Flags for this plugin must be enabled before sourcing it
  export FORGIT_LOG_GRAPH_ENABLE=false
  export FORGIT_NO_ALIASES=true
  export FORGIT_FZF_DEFAULT_OPTS="
  --border rounded
  --reverse
  "
  export FORGIT_LOG_FZF_OPTS='
  --header "Open log with nvim: <Ctrl> + <e>"
  --bind="ctrl-e:execute(echo {} | grep -Eo [a-f0-9]+ | head -1 | xargs git show | nvim -)"
  '
  zinit load wfxr/forgit

  ### Override aliases to `orginal_alias`+i
  alias gai="forgit::add"
  alias gloi="forgit::log"
  alias gbdi="forgit::branch::delete"
  alias gbli="forgit::blame"
  alias gcbi="forgit::checkout::branch"
  alias gcfi="forgit::checkout::file"
  alias gcoi="forgit::checkout::commit"
  alias gcpi="forgit::cherry::pick::from::branch"
  alias gdi="forgit::diff"
  alias gii="forgit::ignore"
  alias grbii="forgit::rebase"
  alias grhi="forgit::reset::head"
  alias gssi="forgit::stash::show"
  alias gcleani="forgit::clean"
  ### If normal alias are set the following orginal alias needs to unset
  ### As no similar alias is in use on OMZP::git
  alias gcti="forgit::checkout::tag"
  alias gfui="forgit::fixup"
  alias grci="forgit::revert::commit"
  alias gspi="forgit::stash::push"

  ### zsh-users/zsh-syntax-highlighting Customize command colors
  ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,underline
  ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,underline
  ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
  ZSH_HIGHLIGHT_STYLES[assign]=fg=green

  ### Aloxaf/fzf-tab integration
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

  ### Add in custom alias & snippets
  ### https://github.com/ohmyzsh/ohmyzsh/wiki/plugins
  ### Local sysadmin related snippets
  zinit snippet OMZP::ssh
  zinit snippet OMZP::sudo
  zinit snippet OMZP::nmap
  zinit snippet OMZP::rsync
  zinit snippet OMZP::systemd
  zinit snippet OMZP::systemadmin
  zinit snippet OMZP::firewalld
  zinit snippet OMZP::ssh-agent
  zinit snippet OMZP::gpg-agent
  #zinit snippet OMZP::command-not-found
  #zinit snippet OMZP::tmux

  ### Local syntax errors snippets
  #zinit snippet OMZP::ufw

  ### Programming related snippets
  zinit snippet OMZP::git
  zinit snippet OMZP::git-commit
  zinit snippet OMZP::rust
  zinit snippet OMZP::perl
  zinit snippet OMZP::python
  zinit snippet OMZP::golang
  zinit snippet OMZP::dotnet

  ### DevOps tools related snippets
  ### Cloud CLI's snippets
  zinit snippet OMZP::aws
  zinit snippet OMZP::azure
  zinit snippet OMZP::doctl
  zinit snippet OMZP::gcloud
  ### IaC snippets
  zinit snippet OMZP::oc
  zinit snippet OMZP::vagrant
  zinit snippet OMZP::ansible
  zinit snippet OMZP::terraform
  zinit snippet OMZP::knife_ssh
  ### Kubernetes snippets
  zinit snippet OMZP::kops
  zinit snippet OMZP::kubectl
  zinit snippet OMZP::minikube
  zinit snippet OMZP::microk8s
  ### Containers snippets
  zinit snippet OMZP::lxd
  zinit snippet OMZP::podman
  zinit snippet OMZP::docker-compose
  ## DB snippets
  zinit snippet OMZP::mongocli
  zinit snippet OMZP::postgres
  ### Other DevOps snippets
  #zinit snippet OMZP::localstack

  ### DevOps errors snippets
  #zinit snippet OMZP::knife
  #zinit snippet OMZP::salt
  #zinit snippet OMZP::redis-cli
  #zinit snippet OMZP::kitchen

  ### Needs docker not podman/docker
  #zinit snippet OMZP::docker

  ### Other tools related snippets
  zinit snippet OMZP::gh
  zinit snippet OMZP::jira
  zinit snippet OMZP::procs
  zinit snippet OMZP::isodate
  zinit snippet OMZP::toolbox
  #zinit snippet OMZP::sigstore

  zinit cdreplay -q

fi
