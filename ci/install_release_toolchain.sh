#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
# TODO: install zip command for all platforms

function install_linux() {
  if ! command -v zip; then
    echo "zip failed to install"
    exit 1
  fi
}

function install_macOS() {
  if ! command -v zip; then
    echo "zip failed to install"
    exit 1
  fi
}

function install_windows() {
  echo "unimplemented"
  exit 1
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