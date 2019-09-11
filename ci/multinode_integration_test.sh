#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ "$JENKINS_VERSION" != "" ]]; then
  PARENT_DIR="$1"
  WORKSPACE="$HOME"
else
  PARENT_DIR=""
  WORKSPACE="$("$CI_DIR/bashify_workspace.sh" "$1")"
  RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
  CARGO_HOME="$WORKSPACE/toolchains/.cargo"
  PATH="$WORKSPACE/toolchains/.cargo/bin:$PATH"
  chmod +x "$WORKSPACE"/toolchains/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"
fi

case "$OSTYPE" in
  msys)
    echo "Multinode Integration Tests don't run under Windows"
    ;;
  Darwin | darwin*)
    echo "Multinode Integration Tests don't run under macOS"
    ;;
  linux*)
    # Remove this line to slow down the build
    export RUSTC_WRAPPER=sccache
    export RUSTFLAGS="-D warnings -Anon-snake-case"

    pushd "$CI_DIR/../multinode_integration_tests"
    ci/all.sh "$PARENT_DIR"
    popd
    ;;
  *)
    exit 1
    ;;
esac
