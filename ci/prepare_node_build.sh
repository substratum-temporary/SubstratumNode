#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
#PARENT_DIR="$1"

WORKSPACE="$("$CI_DIR"/bashify_workspace "$1")"
PATH="$WORKSPACE/.cargo/bin:$PATH"
chmod +x "$WORKSPACE"/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"

echo "Path: $PATH"
echo "First directory in PATH:"
ls -l "$(echo "$PATH" | cut -d: -f1)"
rustc --version
"$CI_DIR/format.sh"
