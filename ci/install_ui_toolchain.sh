#!/bin/bash -ev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

function install_linux() {
  if [[ ! -f "$HOME/.nvm/versions/node/v10.16.3/bin/node" ]]; then
    curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
    sudo apt-get update
    sudo apt-get install -y nodejs
    source "$HOME/.nvm/nvm.sh"
    nvm install 10.16.3
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update
    sudo apt-get install -y yarn
  fi
}

function install_macOS() {
  if [[ ! -f "$HOME/.nvm/versions/node/v10.16.3/bin/node" ]]; then
    brew install node || echo "" # Assume that if installation fails, it's because node is already installed
    source "$HOME/.nvm/nvm.sh"
    nvm install 10.16.3
    npm install -g yarn
  fi
}

function install_windows() {
    echo "Not yet!"
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
