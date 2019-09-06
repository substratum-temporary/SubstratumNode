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
#  rm "/usr/bin/node" || echo "node.js not installed"
#  rm "/usr/bin/nodejs" || echo "node.js not installed"
#  rm "/usr/bin/npm" || echo "npm not installed"
#  rm -r "$HOME/.nvm" || echo "node.js configuration not installed"
#  rm -r "/usr/lib/node_modules" || echo "No node_modules installed"
#  curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
#  sudo apt-get update
#  sudo apt-get install -y nodejs
#  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
#  echo "Looking for node"
#  find / -type d -name node 2> /dev/null || echo "node not found"
#  echo "Looking for nodejs"
#  find / -type d -name nodejs 2> /dev/null || echo "nodejs not found"
#  echo "Looking for .nvm"
#  find / -type d -name .nvm 2> /dev/null || echo ".nvm not found"
#  source "$HOME/.nvm/nvm.sh"
#  nvm install "$NODE_VERSION"

#  mkdir -p "$CACHE_TARGET/usr/bin"
#  mkdir -p "$CACHE_TARGET/usr/lib"
#  cp "/usr/bin/node" "$CACHE_TARGET/usr/bin/node"
#  cp "/usr/bin/node" "$CACHE_TARGET/usr/bin/npm"
#  cp -R "/usr/lib/node_modules/" "$CACHE_TARGET/usr/lib"
#  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

#  rm "/usr/bin/yarn" || echo "yarn not installed"
#  rm -r "$HOME/.yarn" || echo "yarn configuration not installed"
#  sudo npm install -g yarn



#  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#  sudo apt-get update
#  sudo apt-get install -y yarn

  mkdir -p "$CACHE_TARGET/usr/bin"
  cp "/usr/bin/yarn" "$CACHE_TARGET/usr/bin/yarn"
  cp -R "$HOME/.yarn" "$CACHE_TARGET/.yarn"
}

function install_macOS() {
#  rm "/usr/local/bin/node" || echo "node.js not installed"
#  rm "/usr/local/bin/npm" || echo "npm not installed"
#  rm -r "$HOME/.nvm" || echo "node.js configuration not installed"
#  rm -r "/usr/lib/node_modules" || echo "No node_modules installed"
#  brew install node || echo "node.js is already installed"
#  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
#  echo "Looking for node"
#  find / -type d -name node 2> /dev/null || echo "node not found"
#  echo "Looking for nodejs"
#  find / -type d -name nodejs 2> /dev/null || echo "nodejs not found"
#  echo "Looking for .nvm"
#  find / -type d -name .nvm 2> /dev/null || echo ".nvm not found"
#  cat "$HOME/.bashrc"
#  source "$HOME/.nvm/nvm.sh"
#  nvm install "$NODE_VERSION"
#
#  mkdir -p "$CACHE_TARGET/usr/local/bin"
#  mkdir -p "$CACHE_TARGET/usr/local/lib"
#  cp "/usr/local/bin/node" "$CACHE_TARGET/usr/local/bin/node"
#  cp "/usr/local/bin/node" "$CACHE_TARGET/usr/local/bin/npm"
#  cp -R "/usr/local/lib/node_modules/" "$CACHE_TARGET/usr/local/lib"
#  cp -R "$HOME/.nvm" "$CACHE_TARGET/.nvm"

  rm -r "$HOME/.yarn" || echo "yarn not installed"
  npm install -g yarn

  cp "/usr/local/bin/yarn" "$CACHE_TARGET/usr/local/bin/yarn"
  cp -R "$HOME/.yarn" "$CACHE_TARGET/.yarn"
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
