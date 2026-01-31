#!/usr/bin/env bash

BASE_PATH="$HOME"/.local/venvs
UNOSERVER_PATH="$BASE_PATH"/unoserver
UNOSERVER_PATH_BIN="$UNOSERVER_PATH"/bin

if ! [[ "$(command -v virtualenv)" ]] || ! [[ "$(command -v soffice)" ]]; then
  echo "Missing dependcies either virtualenv or Libreoffice bins (soffice)"
fi

if ! [[ -d "$BASE_PATH" ]]; then
  mkdir -p "$BASE_PATH"
fi

if [[ -d "$UNOSERVER_PATH" ]]; then
  echo "Removing old installation"
  rm -rf "$UNOSERVER_PATH"
fi

virtualenv --python=/usr/bin/python3 --system-site-packages  "$UNOSERVER_PATH"
"$UNOSERVER_PATH_BIN"/pip install unoserver
ln -sf "$UNOSERVER_PATH_BIN"/unoserver "$HOME"/.local/bin/unoserver
ln -sf "$UNOSERVER_PATH_BIN"/unoconvert "$HOME"/.local/bin/unoconvert
ln -sf "$UNOSERVER_PATH_BIN"/unocompare "$HOME"/.local/bin/unocompare

