#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ "$1" == "" ]]; then
  CACHE_TARGET="$HOME"
else
  CACHE_TARGET="$1"
fi

function install_linux_macOS() {
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  "$HOME/.cargo/bin/rustup" update
  "$HOME/.cargo/bin/rustup" component add rustfmt
  "$HOME/.cargo/bin/rustup" component add clippy
  "$HOME/.cargo/bin/cargo" install sccache

  cp -R "$HOME/.cargo" "$CACHE_TARGET/.cargo"
}

case "$OSTYPE" in
  Darwin | darwin*)
    install_linux_macOS
    ;;
  linux*)
    install_linux_macOS
    ;;
  *)
    echo "Unrecognized operating system $OSTYPE"
    exit 1
    ;;
esac
