#!/bin/bash

VERSION=$(curl -sSL "https://go.dev/dl/?mode=json" | jq -r '.[0].version' | sed 's/go//')
if ! [ -n "$VERSION" ]; then
  VERSION=1.25.4
fi
INSTALL_DIR="$HOME/.local/installs"
CDATE=$(date +'%Y_%m_%d_%H_%M_%S')
BACKUP_DIR="${INSTALL_DIR}/go_${CDATE}"
GO_PATH="$INSTALL_DIR/go/bin"
TMP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH2=amd64
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH2=arm64
fi

if ! echo "$PATH" | tr ':' '\n' | grep -q "$GO_PATH"; then
  echo "$GO_PATH is not in path, add it before continuing"
  exit 1
else
  echo "$GO_PATH is in path"
fi

if [ -x "$(command -v go)" ]; then
  PRE_INSTALLED_VERSION=$(go version | awk '{print $3}')
  if [ "$PRE_INSTALLED_VERSION" == "go$VERSION" ]; then
      echo "Go $VERSION is already installed no need to do anything"
      exit 0
  fi
fi

[ -d "${INSTALL_DIR}" ] || mkdir -p "$INSTALL_DIR"
if [[ -d "${INSTALL_DIR}/go" ]]; then
  echo "Backup of old installation created as ${BACKUP_DIR}"
  mv "${INSTALL_DIR}/go" "${BACKUP_DIR}"
fi

cd "${TMP_DIR}" || exit 1
echo "Downloading Go $VERSION archive"
wget "https://dl.google.com/go/go${VERSION}.${OS}-${ARCH2}.tar.gz"

echo "Extracting archive"
tar -C "${INSTALL_DIR}" -xvzf "go${VERSION}.${OS}-${ARCH2}.tar.gz"

if [ -x "$(command -v go)" ]; then
    INSTALLED_VERSION=$(go version | awk '{print $3}')
    if [ "$INSTALLED_VERSION" == "go$VERSION" ]; then
        echo "Go $VERSION is installed successfully."
    else
        echo "Installed Go version ($INSTALLED_VERSION) doesn't match the expected version (go$VERSION)."
    fi
else
    echo "Go is not found in the PATH. Check install for errors"
fi

## Clean up
rm -rf "${TMP_DIR}"
