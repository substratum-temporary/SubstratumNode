#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
#PARENT_DIR="$1"

TOOLCHAIN_HOME="$("$CI_DIR"/bashify_workspace.sh "$1")"
export CARGO_HOME="$TOOLCHAIN_HOME/toolchains/.cargo"
export RUSTUP_HOME="$TOOLCHAIN_HOME/toolchains/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"
chmod +x "$CARGO_HOME"/bin/* || echo "Couldn't make .cargo/bin files executable"
find "$RUSTUP_HOME" -type f -ipath "*\/bin/*" -print0 |xargs -0 -I{} chmod +x "{}" || echo "Couldn't make .rustup/**/bin/* files executable"

echo "Path: $PATH"
echo "First directory in PATH:"
ls -la "$(echo "$PATH" | cut -d: -f1)"
echo "Contents of TOOLCHAIN_HOME":
ls -la "$TOOLCHAIN_HOME"
echo "Contents of RUSTUP_HOME:"
ls -la "$RUSTUP_HOME"
echo "settings.toml:"
cat "$RUSTUP_HOME"/settings.toml
echo "which rustc: $(which rustc)"
echo "which rustup: $(which rustup)"
rustup show
rustc --version
"$CI_DIR/format.sh"
