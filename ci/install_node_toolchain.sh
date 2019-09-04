#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

RUSTUP_HOME="$1"
if [[ "$RUSTUP_HOME" == "" ]]; then
  RUSTUP_HOME="$HOME"
fi

function install_linux_macOS() {
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  "$HOME/.cargo/bin/rustup" update
  "$HOME/.cargo/bin/rustup" component add rustfmt
  "$HOME/.cargo/bin/rustup" component add clippy
  "$HOME/.cargo/bin/cargo" install sccache
}

function install_windows() {
  curl https://win.rustup.rs -sSf > /tmp/rustup-init.exe
  /tmp/rustup-init.exe -y
  "$HOME/.cargo/bin/rustup" update
  "$HOME/.cargo/bin/rustup" component add rustfmt
  "$HOME/.cargo/bin/rustup" component add clippy
  "$HOME/.cargo/bin/cargo" install sccache
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
