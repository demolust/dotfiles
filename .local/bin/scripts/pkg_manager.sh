#!/usr/bin/env bash
# pkg_manager.sh - Detects the Linux distribution and provides a common
# set of package management functions.
#
# Usage:
#   source ./pkg_manager.sh
#   pkg_install htop vim
#   pkg_update_all

# Stop on errors
#set -euo pipefail

# --- Global Variables ---
export DISTRO_ID=""          # e.g., "ubuntu", "fedora", "rhel", "arch"
export PKG_MGR=""            # e.g., "apt", "dnf", "pacman", "zypper"
export _SUDO=""              # Will be set to "sudo" if not running as root
export PKG_NONINTERACTIVE="" # Flags for non-interactive installation

# --- Internal Functions ---

# Helper function to print errors
_error() {
  echo >&2 "[ERROR]" "$@"
  exit 1
}

# Sets the _SUDO variable
_check_sudo() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    if ! [[ "$(command -v sudo)" ]]; then
      _error "This script requires root privileges or 'sudo' to be installed"
    fi
    _SUDO="sudo"
  else
    _SUDO=""
  fi
}

# Main function to detect the distribution
_detect_distro() {
  if [ ! -f /etc/os-release ]; then
    _error "Cannot detect distribution: /etc/os-release not found"
  fi

  # Source the os-release file to get ID and ID_LIKE
  #. /etc/os-release
  ID=$(grep -E '^ID=' /etc/os-release | cut -d '=' -f 2)
  ID_LIKE=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d '=' -f 2 || true)

  # Use ID_LIKE first, as it groups derivatives (e.g., Pop!_OS likes 'ubuntu')
  local id_to_check="${ID:-$ID_LIKE}"

  case "$id_to_check" in
  *debian*)
    DISTRO_ID="debian"
    PKG_MGR="apt"
    PKG_NONINTERACTIVE="DEBIAN_FRONTEND=noninteractive"
    ;;
  *ubuntu*)
    DISTRO_ID="ubuntu"
    PKG_MGR="apt"
    PKG_NONINTERACTIVE="DEBIAN_FRONTEND=noninteractive"
    ;;
  *fedora*)
    DISTRO_ID="fedora"
    PKG_MGR="dnf"
    ;;
  *rhel* | *centos* | *rocky* | *almalinux* | *oracle* | *ol*)
    DISTRO_ID="rhel"
    PKG_MGR="dnf"
    ;;
  *arch* | *manjaro*)
    DISTRO_ID="arch"
    PKG_MGR="pacman"
    ;;
  *opensuse-leap*)
    DISTRO_ID="opensuse-leap"
    PKG_MGR="zypper"
    ;;
  *opensuse-tumbleweed* | *tumbleweed*)
    DISTRO_ID="opensuse-tumbleweed"
    PKG_MGR="zypper"
    ;;
  *)
    _error "Unsupported distribution: '$ID' (ID_LIKE='$ID_LIKE')"
    ;;
  esac

  export DISTRO_ID PKG_MGR PKG_NONINTERACTIVE
  echo >&2 "[INFO] Detected Distro: $DISTRO_ID (Package Manager: $PKG_MGR)"
}

# Main function to define the package functions based on PKG_MGR
_define_pkg_functions() {
  case "$PKG_MGR" in
  apt)
    pkg_update_repos() {
      $_SUDO apt update
    }
    pkg_update_repos_user() {
      apt update
    }
    pkg_update_all() {
      $_SUDO $PKG_NONINTERACTIVE apt upgrade -y
      $_SUDO $PKG_NONINTERACTIVE apt autoremove -y
    }
    pkg_install() {
      $_SUDO $PKG_NONINTERACTIVE apt install -y "$@"
    }
    pkg_remove() {
      $_SUDO $PKG_NONINTERACTIVE apt remove -y "$@"
    }
    pkg_info() {
      true
    }
    pkg_info_remote() {
      true
    }
    pkg_info_local() {
      true
    }
    pkg_search_remote() {
      apt-cache search "$@"
    }
    pkg_search_installed() {
      dpkg -l "$@"
    }
    pkg_list_installed() {
      apt list --installed | awk -F'[/ ]' '{print $1 "   " $3}' | column -t
    }
    pkg_list_installed_local() {
      true
    }
    pkg_list_remote() {
      true
    }
    pkg_list_upgradable() {
      apt list --upgradable 2>/dev/null
    }
    pkg_add_repo() {
      # This assumes PPA format for Ubuntu/Debian derivatives
      # Requires software-properties-common
      $_SUDO $PKG_NONINTERACTIVE add-apt-repository -y "$@"
    }
    pkg_remove_repo() {
      $_SUDO $PKG_NONINTERACTIVE add-apt-repository --remove -y "$@"
    }
    pkg_enable_repo() {
      echo >&2 "[WARN] 'pkg_enable_repo' for apt requires manual edits of files on /etc/apt/sources.list.d/ directory"
    }
    pkg_disable_repo() {
      echo >&2 "[WARN] 'pkg_disable_repo' for apt requires manual edits of files on /etc/apt/sources.list.d/ directory"
    }
    pkg_rollback() {
      echo >&2 "[WARN] 'pkg_rollback' is not supported by apt"
      return 1
    }
    pkg_update_check_reboot(){
      [[ -f /var/run/reboot-required ]] && exit 1 || exit 0
    }
    ;;

  dnf)
    pkg_update_repos() {
      $_SUDO dnf makecache
    }
    pkg_update_repos_user() {
      dnf clean all
      dnf makecache
    }
    pkg_update_all() {
      $_SUDO dnf upgrade -y
      $_SUDO dnf autoremove -y
    }
    pkg_install() {
      $_SUDO dnf install -y "$@"
    }
    pkg_remove() {
      $_SUDO dnf remove -y "$@"
    }
    pkg_info() {
      dnf info "$@" 2>/dev/null
    }
    pkg_info_remote() {
      dnf info --available "$@" 2>/dev/null | grep -v '^Available packages$'
    }
    pkg_info_local() {
      rpm -qi "$@"
    }
    pkg_search_remote() {
      dnf search "$@"
    }
    pkg_search_installed() {
      dnf list --installed "$@"
    }
    pkg_list_installed() {
      dnf list --installed
    }
    pkg_list_installed_local() {
      rpm -qa | sort
    }
    pkg_list_remote() {
      dnf list --available 2>/dev/null | awk '{print $1}' | grep -v '^Available$'
    }
    pkg_list_upgradable() {
      dnf check-update 2>/dev/null
    }
    pkg_add_repo() {
      if [[ "$1" =~ .*\.repo$ ]];then
        if  [[ "$(dnf --version | awk 'NR==1 {print $1}')" == "dnf5" ]];then
          $_SUDO dnf config-manager addrepo --overwrite --from-repofile "$1"
        else
          $_SUDO dnf config-manager --add-repo "$1"
        fi
      else
        $_SUDO dnf copr enable -y "$1"
      fi
    }
    pkg_remove_repo() {
      echo >&2 "[WARN] 'pkg_remove_repo' for dnf requires manual edit on files of /etc/yum.repos.d/ files"
    }
    pkg_enable_repo() {
      if  [[ "$(dnf --version | awk 'NR==1 {print $1}')" == "dnf5" ]];then
        $_SUDO dnf config-manager setopt "$1".enabled=1
      else
        $_SUDO dnf config-manager --enable "$1"
      fi
    }
    pkg_disable_repo() {
      if  [[ "$(dnf --version | awk 'NR==1 {print $1}')" == "dnf5" ]];then
        $_SUDO dnf config-manager setopt "$1".enabled=0
      else
        $_SUDO dnf config-manager --disable "$1"
      fi
    }
    pkg_rollback() {
      if [ -z "${1:-}" ]; then
        echo >&2 "[ERROR] 'pkg_rollback' requires a transaction ID"
        $_SUDO dnf history list
        return 1
      fi
      $_SUDO dnf history rollback "$1"
    }
    pkg_update_check_reboot(){
      $_SUDO dnf needs-restarting -r
    }
    ;;

  pacman)
    pkg_update_repos() {
      $_SUDO pacman -Syy
    }
    pkg_update_repos_user() {
      pacman -Syy
    }
    pkg_update_all() {
      $_SUDO pacman -Syu --noconfirm
      orphans=$(pkg_get_orphans || true)
      if [[ -n $orphans ]]; then
        for pkg in $orphans; do
          pkg_remove "$pkg" || true
        done
      fi
    }
    pkg_get_orphans(){
      pacman -Qtdq
    }
    pkg_install() {
      $_SUDO pacman -S --noconfirm --needed "$@"
    }
    pkg_remove() {
      $_SUDO pacman -Rns --noconfirm "$@"
    }
    pkg_info() {
      pacman -Sii "$@"
    }
    pkg_info_remote() {
      pacman -Sii "$@"
    }
    pkg_info_local() {
      pacman -Qi "$@"
    }
    pkg_search_remote() {
      pacman -Ss "$@"
    }
    pkg_search_installed() {
      pacman -Qs "$@"
    }
    pkg_list_installed() {
      pacman -Q
    }
    pkg_list_installed_local() {
      pacman -Q
    }
    pkg_list_remote() {
      pacman -Slq
    }
    pkg_list_upgradable() {
      pacman -Qu 2>/dev/null
    }
    pkg_add_repo() {
      echo >&2 "[WARN] 'pkg_add_repo' for pacman requires manual edit of /etc/pacman.conf"
    }
    pkg_remove_repo() {
      echo >&2 "[WARN] 'pkg_remove_repo' for pacman requires manual edit of /etc/pacman.conf"
    }
    pkg_enable_repo() {
      echo >&2 "[WARN] 'pkg_enable_repo' for pacman requires manual edit of /etc/pacman.conf"
    }
    pkg_disable_repo() {
      echo >&2 "[WARN] 'pkg_disable_repo' for pacman requires manual edit of /etc/pacman.conf"
    }
    pkg_rollback() {
      echo >&2 "[WARN] 'pkg_rollback' is not directly supported by pacman. Consider 'downgrade' tool"
      return 1
    }
    pkg_update_check_reboot(){
    [[ "$(uname -r | sed 's/-arch/\.arch/')" == "$(pacman -Q linux | awk '{print $2}')" ]] && exit 0 || exit 1
    }
    ;;

  zypper)
    pkg_update_repos() {
      $_SUDO zypper refresh
    }
    pkg_update_repos_user() {
      zypper refresh
    }
    pkg_update_all() {
      $_SUDO zypper --non-interactive dup
      orphans=$(pkg_get_orphans || true)
      if [[ -n $orphans ]]; then
        for pkg in $orphans; do
          pkg_remove "$pkg" || true
        done
      fi
    }
    pkg_get_orphans(){
      zypper packages --orphaned 2>/dev/null | awk '{print $5}' | grep -v Name | sed '/^[[:space:]]*$/d'
    }
    pkg_install() {
      $_SUDO zypper --non-interactive install "$@"
    }
    pkg_remove() {
      $_SUDO zypper --non-interactive remove "$@"
    }
    pkg_info() {
      zypper info "$@"
    }
    pkg_info_remote() {
      zypper info "$@"
    }
    pkg_info_local() {
      rpm -qi "$@"
    }
    pkg_search_remote() {
      zypper search "$@"
    }
    pkg_search_installed() {
      zypper search --installed-only "$@"
    }
    pkg_list_installed() {
      zypper search --installed-only --details | awk '{print $3 "  " $7 "  " $11}' | column -t
    }
    pkg_list_installed_local() {
      rpm -qa | sort
    }
    pkg_list_remote() {
      true
    }
    pkg_list_upgradable() {
      zypper list-updates 2>/dev/null
    }
    pkg_add_repo() {
      # Assumes arguments are passed directly to 'zypper ar'
      # e.g., pkg_add_repo <URL> <alias>
      $_SUDO zypper --non-interactive ar "$@"
    }
    pkg_remove_repo() {
      # Assumes $1 is the repo alias or URL
      $_SUDO zypper --non-interactive rr "$1"
    }
    pkg_enable_repo() {
      $_SUDO zypper mr -e "$1"
    }
    pkg_disable_repo() {
      $_SUDO zypper mr -d "$1"
    }
    pkg_rollback() {
      if [ -z "${1:-}" ]; then
        echo >&2 "[ERROR] 'pkg_rollback' requires a transaction ID or number"
        $_SUDO zypper history
        return 1
      fi
      $_SUDO zypper --non-interactive rollback "$1"
    }
    pkg_update_check_reboot(){
      $_SUDO zypper needs-rebooting
    }
    ;;
  esac
}

# --- Main Execution ---
# Only run if this script is not being sourced
# (or rather, run when sourced)

_check_sudo
_detect_distro
_define_pkg_functions
