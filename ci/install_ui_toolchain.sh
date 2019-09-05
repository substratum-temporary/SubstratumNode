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
  curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
  sudo apt-get update
  sudo apt-get install -y nodejs
  ls -lR ~
  source "$HOME/.nvm/nvm.sh"
  nvm install "$NODE_VERSION"

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install -y yarn

  cp -R "$HOME/.yarn" "$CACHE_TARGET/.yarn"
}

function install_macOS() {
  brew install node || echo "" # Assume that if installation fails, it's because node is already installed
  ls -lR ~
  source "$HOME/.nvm/nvm.sh"
  nvm install "$NODE_VERSION"

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

  npm install -g yarn

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"
}

function install_windows() {
  CACHE_TARGET=$(echo $CACHE_TARGET | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|g')
  msiexec.exe //a "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-x64.msi" //quiet
  ls -lR ~
  source "$HOME/.nvm/nvm.sh"
  nvm install "$NODE_VERSION"

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

  npm install -g yarn

  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"
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
ls -lR ~
