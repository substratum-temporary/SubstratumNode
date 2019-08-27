#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ $(which "$HOME/.cargo/bin/rustc") == "" ]]; then
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  "$HOME/.cargo/bin/rustup" update
  "$HOME/.cargo/bin/cargo" install sccache
  "$HOME/.cargo/bin/rustup" component add rustfmt
  "$HOME/.cargo/bin/rustup" component add clippy
fi
