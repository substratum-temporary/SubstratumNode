#!/bin/bash -xv
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORKSPACE="$1"

export PATH="$PATH:$HOME/.cargo/bin"
source "$CI_DIR"/../../ci/environment.sh "$WORKSPACE"

export RUST_BACKTRACE=full
export RUSTFLAGS="-D warnings -Anon-snake-case"
umask 000

pushd "$CI_DIR/.."
cargo test --release -- --nocapture --test-threads=1 _integration
BUILD_RESULT=$?
chmod -R 777 target
popd
exit "$BUILD_RESULT"
