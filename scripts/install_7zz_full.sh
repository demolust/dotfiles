#!/usr/bin/env bash

# Install the latest upstream 7-Zip console binary. Fedora omits the RAR
# handler from its packaged 7z, while upstream's standalone 7zz includes it.
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
EXTRACT_DIR="$(mktemp -d)"
BKP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
BIN='7zz'
DOWNLOAD_PAGE='https://www.7-zip.org/download.html'

case "$ARCH" in
  x86_64) ARCH2='x64' ;;
  aarch64) ARCH2='arm64' ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

mkdir -p "$INSTALL_DIR"

cleanup() {
  rm -rf "$TMP_DIR" "$EXTRACT_DIR" "$BKP_DIR"
}
trap cleanup EXIT

echo "Checking for the latest upstream version of $BIN"
ARCHIVE_PATH="$({
  curl -fsSL "$DOWNLOAD_PAGE" \
    | grep -oE "a/7z[0-9]+-linux-${ARCH2}\\.tar\\.xz" \
    | head -n 1
} || true)"

if [[ -z "$ARCHIVE_PATH" ]]; then
  echo "Could not find a Linux $ARCH2 archive on $DOWNLOAD_PAGE" >&2
  exit 1
fi

ASSET_URL="https://www.7-zip.org/$ARCHIVE_PATH"
ASSET_NAME="$(basename "$ASSET_URL")"

echo "Downloading $ASSET_URL"
cd "$TMP_DIR"
curl -fsSLO "$ASSET_URL"

if [[ ! -f "$ASSET_NAME" ]]; then
  echo "Download of $ASSET_URL failed, retry the script" >&2
  exit 1
fi

tar -C "$EXTRACT_DIR" -xJf "$ASSET_NAME"
FOUND_BIN="$(find "$EXTRACT_DIR" -type f -name "$BIN" | head -n 1)"

if [[ -z "$FOUND_BIN" ]]; then
  echo "Installation of $BIN failed, there is no binary in $ASSET_NAME" >&2
  exit 1
fi

BKP_BIN="$(command -v "$BIN" || true)"
if [[ "$BKP_BIN" == "$INSTALL_DIR/"* ]]; then
  echo "Creating a backup of old binary"
  rsync -azPq "$BKP_BIN" "$BKP_DIR/$BIN"
fi

install -m 0755 "$FOUND_BIN" "$INSTALL_DIR/$BIN"
echo "$BIN installed to $INSTALL_DIR"

echo "Ensuring correct installation of $BIN"
if ! "$INSTALL_DIR/$BIN" i >/dev/null; then
  echo "Installation of $BIN failed, removing binary"
  rm -vf "$INSTALL_DIR/$BIN"
  if [[ -f "$BKP_DIR/$BIN" ]]; then
    echo "Restoring old binary"
    rsync -azPq "$BKP_DIR/$BIN" "$INSTALL_DIR/$BIN"
    echo "Restored previous working $BIN binary"
  fi
  exit 1
fi
