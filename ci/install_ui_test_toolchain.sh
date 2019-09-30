#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

function install_linux() {
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google.list
  sudo apt update
  sudo apt install -y google-chrome-stable xvfb
}

function install_macOS() {
  brew update
  brew install cask || echo "Cask already installed"
  brew cask install google-chrome || echo "Chrome already installed"
}

function install_windows() {
  echo "Checking Google Chrome version ..."
  wmic product where "name like 'Google Chrome'" get version || \
    echo "No Google Chrome instance was found"
  echo "Attempting to uninstall Google Chrome ..."
  wmic product where "name like 'Google Chrome'" call uninstall //nointeractive || \
    echo "No Google Chrome instance was found"
  echo "Attempting to install latest Google Chrome ..."
  if ! choco install -y googlechrome; then
    echo "Google Chrome failed to install... trying to continue anyways."
    echo "Dumping MSI install log out to console ..."
    grep -B10 "Return Value 3" "$(cygpath -u "C:\Users\VssAdministrator\AppData\Local\Temp\chocolatey\GoogleChrome.77.0.3865.90.MsiInstall.log")"
  fi
  echo "Checking Google Chrome version ..."
  wmic product where "name like 'Google Chrome'" get version || \
    echo "No Google Chrome instance was found"
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
