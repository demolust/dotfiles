#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH2=amd64
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH2=arm64
fi

mkdir -p "$INSTALL_DIR"

# List of tools with their GitHub repo and how to check their version
declare -A tools=(
  # Format: [name]='github_repo:binary_name:version_cmd:"base_asset_pattern"'
  [eza]='eza-community/eza:eza:eza --version | awk '\''NR==2 {print $1}'\''| sed '\''s/^v//'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [bat]='sharkdp/bat:bat:bat --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [fd]='sharkdp/fd:fd:fd --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [starship]='starship/starship:starship:starship --version | awk '\''NR==1 {print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [delta]='dandavison/delta:delta:delta --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [dust]='bootandy/dust:dust:dust --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [sd]='chmln/sd:sd:sd --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [uv]='astral-sh/uv:uv:uv --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [uvx]='astral-sh/uv:uvx:uvx --version | awk '\''{print $2}'\'':"uv.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [yazi]='sxyazi/yazi:yazi:yazi --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [ya]='sxyazi/yazi:ya:ya --version | awk '\''{print $2}'\'':"yazi.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [procs]='dalance/procs:procs:procs --version | awk '\''{print $2}'\'' |sed '\''s/"//'\'':"$bin.*$ARCH.*$OS.*(tar.gz|zip)"'
  [glow]='charmbracelet/glow:glow:glow --version | awk '\''{print $3}'\'':"$bin.*$OS.*($ARCH|$ARCH2).*(tar.gz|zip)"'
  [lazygit]='jesseduffield/lazygit:lazygit:lazygit --version | awk -F '\'','\'' '\''{print $4}'\'' | cut -d '\''='\'' -f 2:"$bin.*$OS.*($ARCH|$ARCH2).*(tar.gz|zip)"'
  [fzf]='junegunn/fzf:fzf:fzf --version | awk '\''{print $1}'\'':"$bin.*$OS.*$ARCH2.*(tar.gz|zip)"'
  [lf]='gokcehan/lf:lf:lf --version:"$bin.*$OS.*$ARCH2.*(tar.gz|zip)"'
  [ripgrep]='BurntSushi/ripgrep:rg:rg --version | awk '\''NR==1 {print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [zoxide]='ajeetdsouza/zoxide:zoxide:zoxide --version | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
  [xh]='ducaale/xh:xh:xh --version | head -n 1 | awk '\''{print $2}'\'':"$bin.*$ARCH.*$OS.*gnu.*(tar.gz|zip)"'
)

download_and_install() {
  local repo="$1"
  local bin="$2"
  local version_cmd="$3"
  local base_asset_pattern="$4"

  echo "Checking for the latest version of $bin via the GitHub API"

  # GitHub API to get latest release info
  api_url="https://api.github.com/repos/$repo/releases/latest"
  release_json=$(curl -sL "$api_url")

  latest_version=$(echo "$release_json" | jq -r '.tag_name' | sed 's/^v//')
  if [[ -z "$latest_version" || "$latest_version" == "null" ]]; then
    echo "Could not get latest version for $bin"
    printf "\n"
    return
  fi

  # Check installed version
  if command -v "$bin" &>/dev/null; then
    installed_version=$(eval "$version_cmd" || echo "")
    echo "$bin installed version is: $installed_version"
    if [[ "$installed_version" == "$latest_version" ]]; then
      echo "$bin is up to date ($installed_version)"
      printf "\n"
      return
    else
      echo "Updating $bin: $installed_version -> $latest_version"
    fi
  else
    echo "$bin not installed, installing $latest_version"
  fi

  asset_pattern=$(eval echo eval "$base_asset_pattern" | sed 's/eval //g')
  # Find asset (binary or archive)
  asset_url=$(echo "$release_json" | jq -r \
    ".assets[] | select(.name | test(\"$asset_pattern\"; \"i\")).browser_download_url" | head -1)

  if [[ -z "$asset_url" ]]; then
    echo "No asset matching the current OS=$OS & ARCH=$ARCH for $bin, skipping download and installation, check manually for the release on https://github.com/$repo/releases/latest"
    printf "\n"
    return
  fi

  asset_name=$(basename "$asset_url")
  cd "$TMP_DIR"
  curl -sLO "$asset_url"

  # Extract if archive
  if [[ "$asset_name" =~ \.tar\.gz$ ]]; then
    tar -xzf "$asset_name"
    found_bin=$(find . -type f -name "$bin" | head -1)
    mv "$found_bin" "$INSTALL_DIR/"
  elif [[ "$asset_name" =~ \.tgz$ ]]; then
    tar -xzf "$asset_name"
    found_bin=$(find . -type f -name "$bin" | head -1)
    mv "$found_bin" "$INSTALL_DIR/"
  elif [[ "$asset_name" =~ \.zip$ ]]; then
    unzip -q -o "$asset_name"
    found_bin=$(find . -type f -name "$bin" | head -1)
    mv "$found_bin" "$INSTALL_DIR/"
  else
    mv "$asset_name" "$INSTALL_DIR/$bin"
    chmod +x "$INSTALL_DIR/$bin"
  fi

  echo "$bin installed to $INSTALL_DIR"

  echo "Ensuring correct installation of $bin"
  if ! $bin --version > /dev/null; then
     echo "Installation of $bin failed, removing binary"
     rm -vf "$INSTALL_DIR/$bin"
     echo "Check manually for the failure and info on the release notes on https://github.com/$repo/releases/latest"
  fi
  
  printf "\n"

}

for name in "${!tools[@]}"; do
  IFS=':' read -r repo bin version_cmd base_asset_pattern <<< "${tools[$name]}"
  download_and_install "$repo" "$bin" "$version_cmd" "$base_asset_pattern"
done

# Clean up
rm -rf "$TMP_DIR"
echo "All done!"

