#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ "$1" == "" ]]; then
  CACHE_TARGET="$HOME"
else
  CACHE_TARGET="$1"
fi

function install_linux_macOS() {
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  common
}

function install_windows() {
  if [[ "$CACHE_TARGET" =~ ^([A-Za-z]):(.*) ]]; then
    CACHE_TARGET="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  fi
  curl https://win.rustup.rs -sSf > /tmp/rustup-init.exe
  /tmp/rustup-init.exe -y
  common
}

function common() {
  "$HOME/.cargo/bin/rustup" update
  "$HOME/.cargo/bin/rustup" component add rustfmt
  "$HOME/.cargo/bin/rustup" component add clippy
  "$HOME/.cargo/bin/cargo" install sccache

  cp -R "$HOME/.cargo" "$CACHE_TARGET/.cargo"
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
