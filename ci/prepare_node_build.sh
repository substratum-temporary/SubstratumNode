#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
TOOLCHAIN_HOME="$1"

source "$CI_DIR"/environment.sh "$TOOLCHAIN_HOME"

echo "Path: $PATH"
echo "which rustc: $(which rustc)"
echo "which rustup: $(which rustup)"
rustup show
rustc --version
"$CI_DIR/format.sh"
