#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

function install_linux_macOS() {
  if [[ $(which "$HOME/.cargo/bin/rustc") == "" ]]; then
    curl https://sh.rustup.rs -sSf | bash -s -- -y
    "$HOME/.cargo/bin/rustup" update
    "$HOME/.cargo/bin/rustup" component add rustfmt
    "$HOME/.cargo/bin/rustup" component add clippy
  fi

  if [[ $(which "$HOME/.cargo/bin/sccache") == "" ]]; then
    "$HOME/.cargo/bin/cargo" install sccache
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
    install_linux_macOS
    ;;
  linux*)
    install_linux_macOS
    ;;
  *)
    exit 1
    ;;
esac
