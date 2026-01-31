#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(dirname "$0")"
YAML_FILE="${SCRIPT_DIR}/packages.yml"

if [ -f "${SCRIPT_DIR}/pkg_manager.sh" ]; then
  source "${SCRIPT_DIR}/pkg_manager.sh"
else
  echo "Error: ${SCRIPT_DIR}/pkg_manager.sh not found"
  exit 1
fi

if ! [ -f "${YAML_FILE}" ]; then
  echo "Error: ${YAML_FILE} not found"
  exit 1
fi

echo "[INFO] detected OS: $DISTRO_ID"
echo "[INFO] Updating initial repo metadata"
pkg_update_repos

YQ_BIN="/tmp/yq_bootstrap"
install_yq() {
  echo "[INFO] bootstrapping yq parser"
  local YQ_VERSION="v4.48.2"
  local YQ_BINARY

  if [[ "$(uname -m)" == "aarch64" ]]; then
    YQ_BINARY="yq_linux_arm64"
  else
    YQ_BINARY="yq_linux_amd64"
  fi

  if ! [[ "$(command -v curl)" ]]; then
    echo "[INFO] curl missing, attempting to install"
    pkg_install curl
  fi

  curl -s -L -o "$YQ_BIN" "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}"
  chmod +x "$YQ_BIN"
}

if [ ! -f "$YQ_BIN" ]; then
  install_yq
fi

# $1 = Array of package strings
resolve_subshells() {
  local item_list=("$@")
  local resolved_items=()
  local item
  local expanded_item

  for item in "${item_list[@]}"; do
    if [[ "$item" == *\$\(*\)* ]]; then
      # Uses 'eval' to force the shell to execute the command substitution
      # and resolve the string
      # Uses printf to safely capture the evaluated string

      # To safely evaluate the expression while still retaining spaces
      # and other characters, the evaluation is wrapped in an inner shell call
      # to ensure the substitution happens

      # Using 'eval' to execute the shell substitution inside the string so
      # that if the command fails (e.g., 'rpm -E %fedora' on Ubuntu), it might
      # result in an empty string or an error, so need to do error checking
      expanded_item=$(eval printf -- %s "$item")

      if [ -n "$expanded_item" ] && [ "$expanded_item" != "$item" ]; then
        resolved_items+=("$expanded_item")
      else
        resolved_items+=("$item")
      fi
    else
      resolved_items+=("$item")
    fi
  done

  printf '%s ' "${resolved_items[@]}"
}

# $1 = State (present/absent)
# $2 = Prerequisite (true/false)
get_packages_from_yaml() {
  local state=$1
  local prerequisite=$2
  state="$state" prerequisite="$prerequisite" "$YQ_BIN" ".[].tasks.[]
  | select(.when | contains(env(DISTRO_ID))) | .block[]
  | select(.package.state == env(state))
  | select((env(prerequisite) == true and (.package.prerequisite == true))
  or (env(prerequisite) == false and (.package.prerequisite == null or .package.prerequisite == false)))
  | .package.name | (.[] // .)" "$YAML_FILE"
}

# $1 = State (present/absent)
get_repos_from_yaml() {
  local state=$1
  state="$state" "$YQ_BIN" ".[].tasks.[] | select(.when | contains(env(DISTRO_ID))) | .block[] | select(.repository.state == env(state)) | .repository.repo_list | (.[] // .)" "$YAML_FILE"
}

echo "------------------------------------------------"
echo "[STEP 1] Disabling Repositories for $DISTRO_ID"
echo "------------------------------------------------"

mapfile -t REPOS_TO_DISABLE < <(get_repos_from_yaml "disabled")
REPOS_TO_DISABLE=($(resolve_subshells "${REPOS_TO_DISABLE[@]}"))

if [ ${#REPOS_TO_DISABLE[@]} -eq 0 ]; then
  echo "[INFO] No explicit repositories defined for disabling in $YAML_FILE"
else
  echo "[INFO] Found repositories to disable: ${REPOS_TO_DISABLE[*]}"
  for repo in "${REPOS_TO_DISABLE[@]}"; do
    echo "[INFO] Disabling repository: $repo"
    pkg_disable_repo "$repo"
  done
  echo "[INFO] Repositories added. Updating metadata"
  pkg_update_repos
fi

echo "------------------------------------------------"
echo "[STEP 2] Enabling Repositories for $DISTRO_ID"
echo "------------------------------------------------"

mapfile -t REPOS_TO_ENABLE < <(get_repos_from_yaml "enabled")
REPOS_TO_ENABLE=($(resolve_subshells "${REPOS_TO_ENABLE[@]}"))

if [ ${#REPOS_TO_ENABLE[@]} -eq 0 ]; then
  echo "[INFO] No explicit repositories defined for enabling in $YAML_FILE"
else
  echo "[INFO] Found repositories to enable: ${REPOS_TO_ENABLE[*]}"
  for repo in "${REPOS_TO_ENABLE[@]}"; do
    echo "[INFO] Enabling repository: $repo"
    pkg_enable_repo "$repo"
  done
  echo "[INFO] Repositories added. Updating metadata"
  pkg_update_repos
fi

echo "------------------------------------------------"
echo "[STEP 3] Adding New Repositories for $DISTRO_ID"
echo "------------------------------------------------"

mapfile -t REPOS_TO_ADD < <(get_repos_from_yaml "present")
REPOS_TO_ADD=($(resolve_subshells "${REPOS_TO_ADD[@]}"))

if [ ${#REPOS_TO_ADD[@]} -eq 0 ]; then
  echo "[INFO] No explicit repositories defined for addition in $YAML_FILE"
else
  echo "[INFO] Found repositories: ${REPOS_TO_ADD[*]}"
  for repo in "${REPOS_TO_ADD[@]}"; do
    echo "[INFO] Adding repository: $repo"
    pkg_add_repo "$repo"
  done
  echo "[INFO] Repositories added. Updating metadata"
  pkg_update_repos
fi

echo "------------------------------------------------"
echo "[STEP 4] Removing Conflicting Packages"
echo "------------------------------------------------"

mapfile -t PACKAGES_TO_REMOVE < <(get_packages_from_yaml "absent" "false")
PACKAGES_TO_REMOVE=($(resolve_subshells "${PACKAGES_TO_REMOVE[@]}"))

if [ ${#PACKAGES_TO_REMOVE[@]} -eq 0 ]; then
  echo "[INFO] No packages marked for removal"
else
  echo "[INFO] Removing: ${PACKAGES_TO_REMOVE[*]}"
  pkg_remove "${PACKAGES_TO_REMOVE[@]}"
fi

echo "------------------------------------------------"
echo "[STEP 5] Installing Packages Requisites for $DISTRO_ID"
echo "------------------------------------------------"

mapfile -t PRE_PACKAGES_TO_INSTALL < <(get_packages_from_yaml "present" "true")
PRE_PACKAGES_TO_INSTALL=($(resolve_subshells "${PRE_PACKAGES_TO_INSTALL[@]}"))

if [ ${#PRE_PACKAGES_TO_INSTALL[@]} -eq 0 ]; then
  echo "[INFO] No packages defined for installation in $YAML_FILE for $DISTRO_ID"
else
  echo "[INFO] Found packages: ${PRE_PACKAGES_TO_INSTALL[*]}"
  pkg_install "${PRE_PACKAGES_TO_INSTALL[@]}"
fi

echo "------------------------------------------------"
echo "[STEP 6] Installing Packages for $DISTRO_ID"
echo "------------------------------------------------"

mapfile -t PACKAGES_TO_INSTALL < <(get_packages_from_yaml "present" "false")
PACKAGES_TO_INSTALL=($(resolve_subshells "${PACKAGES_TO_INSTALL[@]}"))

if [ ${#PACKAGES_TO_INSTALL[@]} -eq 0 ]; then
  echo "[INFO] No packages defined for installation in $YAML_FILE for $DISTRO_ID"
else
  echo "[INFO] Found packages: ${PACKAGES_TO_INSTALL[*]}"
  pkg_install "${PACKAGES_TO_INSTALL[@]}"
fi

echo "------------------------------------------------"
echo "[INFO] Cleaning up"
rm -f "$YQ_BIN"
echo "[SUCCESS] Bootstrap complete"
