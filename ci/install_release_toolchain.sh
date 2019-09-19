#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

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
  ZIP_DOWNLOAD_URL="https://www.7-zip.org/a/7z1900-x64.exe"
  curl "$ZIP_DOWNLOAD_URL" > "$TEMP/7z-x64.exe"
  cmd //C "echo.>%TEMP%\7z-x64.exe:Zone.Identifier"
  "$TEMP/7z-x64.exe" //S //D="/7-Zip"
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