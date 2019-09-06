#!/bin/bash -ev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ "$1" == "" ]]; then
  CACHE_TARGET="$HOME"
else
  CACHE_TARGET="$1"
fi

if [[ "$2" == "" ]]; then
  NODE_VERSION="10.16.3"
else
  NODE_VERSION="$2"
fi

function install_linux() {
  rm "/usr/bin/yarn" || echo "yarn not installed"
  rm -r "$HOME/.yarn" || echo "yarn configuration not installed"
  sudo npm install -g yarn

  mkdir -p "$CACHE_TARGET/usr/bin"
  cp "/usr/bin/yarn" "$CACHE_TARGET/usr/bin/yarn"
}

function install_macOS() {
  rm "/usr/local/bin/yarn" || echo "yarn not installed"
  rm -r "$HOME/.yarn" || echo "yarn configuration not installed"
  npm install -g yarn

  mkdir -p "$CACHE_TARGET/usr/local/bin"
  cp "/usr/local/bin/yarn" "$CACHE_TARGET/usr/local/bin/yarn"
}

function install_windows() {
  CACHE_TARGET=$(echo $CACHE_TARGET | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|g')
  rm -r "$HOME/.nvm" || echo "node.js not installed"
  msiexec.exe //a "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-x64.msi" //quiet
  nvm install "$NODE_VERSION"

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

  rm -r "$HOME/.yarn" || echo "yarn not installed"
  npm install -g yarn

  cp -R "$HOME/.yarn" "$CACHE_TARGET/.yarn"
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
    echo "Unrecognized operating system $OSTYPE"
    exit 1
    ;;
esac
