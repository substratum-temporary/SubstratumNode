#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
#PARENT_DIR="$1"

WORKSPACE="$("$CI_DIR"/bashify_workspace.sh "$1")"
CARGO_HOME="$WORKSPACE/toolchains/.cargo"
RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
PATH="$WORKSPACE/toolchains/.cargo/bin:$PATH"
chmod +x "$WORKSPACE"/toolchains/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"

echo "Path: $PATH"
echo "First directory in PATH:"
ls -la "$(echo "$PATH" | cut -d: -f1)"
echo "Contents of WORKSPACE":
ls -la "$WORKSPACE"
echo "Contents of RUSTUP_HOME:"
ls -la "$RUSTUP_HOME"
echo "settings.toml:"
cat "$RUSTUP_HOME"/settings.toml
echo "which rust: $(which rust)"
rustc --version
"$CI_DIR/format.sh"
