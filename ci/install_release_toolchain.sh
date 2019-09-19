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
  choco install 7zip.install
  choco install -y windows-sdk-10.1

  echo "which signtool: $(which signtool)"
  cat "/c/ProgramData/chocolatey/logs/chocolatey.log"
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