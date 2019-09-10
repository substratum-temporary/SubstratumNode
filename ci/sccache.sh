#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

WORKSPACE="$("$CI_DIR"/bashify_workspace "$1")"
PATH="$WORKSPACE/.cargo/bin:$PATH"
chmod +x "$WORKSPACE"/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"

cargo install sccache || echo "sccache already installed"
sccache --start-server || echo "sccache server already running"
