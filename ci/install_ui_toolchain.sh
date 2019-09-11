#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

TOOLCHAIN_HOME="$("$CI_DIR"/bashify_workspace.sh "$1")"

if [[ "$2" == "" ]]; then
  NODE_VERSION="10.16.3"
else
  NODE_VERSION="$2"
fi

function install_linux() {
  rm "/usr/bin/yarn" || echo "yarn not installed"
  rm -r "$HOME/.yarn" || echo "yarn configuration not installed"
  sudo npm install -g yarn

  mkdir -p "$TOOLCHAIN_HOME/usr/bin"
  cp "/usr/bin/yarn" "$TOOLCHAIN_HOME/usr/bin/yarn"
}

function install_macOS() {
  rm "/usr/local/bin/yarn" || echo "yarn not installed"
  rm -r "$HOME/.yarn" || echo "yarn configuration not installed"
  npm install -g yarn

  mkdir -p "$TOOLCHAIN_HOME/usr/local/bin"
  cp "/usr/local/bin/yarn" "$TOOLCHAIN_HOME/usr/local/bin/yarn"
}

function install_windows() {
  rm -r "$HOME/.nvm" || echo "node.js not installed"
  msiexec.exe //a "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-x64.msi" //quiet
  nvm install "$NODE_VERSION"

  cp -R "$HOME/.nvm" "$TOOLCHAIN_HOME/.nvm"

  rm -r "$HOME/.yarn" || echo "yarn not installed"
  npm install -g yarn

  cp -R "$HOME/.yarn" "$TOOLCHAIN_HOME/.yarn"
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
