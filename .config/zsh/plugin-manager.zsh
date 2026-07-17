############################### PLUGIN MANAGER CONFIG ###############################
### Set the directory where zinit and the plugins will be stored
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
ZINIT_CACHE_DIR="${XDG_CACHE_HOME}/zinit"

### Ensure zinit is always present by git cloning it
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

### Source zinit
source "${ZINIT_HOME}/zinit.zsh"

### Create the zinit snippet completitions cache directory
ZINIT_CACHE_DIR_COMPLETITIONS="${ZSH_CACHE_DIR}/completions"
if [ ! -d "${ZINIT_CACHE_DIR_COMPLETITIONS}" ]; then
  mkdir -p "${ZINIT_CACHE_DIR_COMPLETITIONS}"
fi
