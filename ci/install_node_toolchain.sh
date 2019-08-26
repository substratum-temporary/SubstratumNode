#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ $(which "$HOME/.cargo/bin/rustc") == "" ]]; then
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  rustup update
  rustup component add rustfmt
  rustup component add clippy
fi
