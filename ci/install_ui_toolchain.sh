#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ $(which yarn) == "" ]]; then
  curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
  sudo apt-get update
  sudo apt-get install -y nodejs
  source "$HOME/.nvm/nvm.sh"
  nvm install 10.16.3
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install -y yarn xvfb
else
  source "$HOME/.nvm/nvm.sh"
  nvm install 10.16.3
fi
