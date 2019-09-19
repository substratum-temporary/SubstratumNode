#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ "$1" == "" ]]; then
  CACHE_TARGET="$HOME"
else
  CACHE_TARGET="$1"
fi

function install_linux() {
  if ! command -v zip; then
    echo "zip command not found"
    exit 1
  fi
}

function install_macOS() {
  if ! command -v zip; then
    echo "zip command not found"
    exit 1
  fi
}

function install_windows() {
  CACHE_TARGET="$("$CI_DIR"/bashify_workspace.sh "$CACHE_TARGET")"
  ZIP_DOWNLOAD_URL="https://www.7-zip.org/a/7z1900-x64.exe"
  curl "$ZIP_DOWNLOAD_URL" > "$TEMP/7z-x64.exe"
  cmd //C "echo.>%TEMP%\7z-x64.exe:Zone.Identifier"
  "$TEMP/7z-x64.exe" //S //D="$CACHE_TARGET/7-Zip"

  choco install -y windows-sdk-10.0

  echo "which signtool: $(which signtool)"
  cat "/ProgramData/chocolatey/logs/chocolatey.log"
}

case "$OSTYPE" in
  msys)
    install_windows
    ;;
  Darwin | darwin*)
    install_macOS
    ;;
  linux*)
    install_linux
    ;;
  *)
    exit 1
    ;;
esac