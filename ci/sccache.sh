#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

WORKSPACE="$("$CI_DIR"/bashify_workspace.sh "$1")"
CARGO_HOME="$WORKSPACE/.cargo"
RUSTUP_HOME="$WORKSPACE/.rustup"
PATH="$WORKSPACE/.cargo/bin:$PATH"
chmod +x "$WORKSPACE"/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"

cargo install sccache || echo "sccache already installed"
sccache --start-server || echo "sccache server already running"
