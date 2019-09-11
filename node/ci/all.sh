#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ "$JENKINS_VERSION" != "" ]]; then
  NODE_PARENT_DIR="$1"
  WORKSPACE="$HOME"
else
  NODE_PARENT_DIR=""
  WORKSPACE="$("$CI_DIR/../../ci/bashify_workspace.sh" "$1")"
  export CARGO_HOME="$WORKSPACE/toolchains/.cargo"
  export RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
  export PATH="$CARGO_HOME/bin:$PATH"
  chmod +x "$CARGO_HOME"/bin/* || echo "Couldn't make .cargo/bin files executable"
  find "$RUSTUP_HOME" -type f -ipath "*\/bin/*" -print0 |xargs -0 -I{} chmod +x "{}" || echo "Couldn't make .rustup/**/bin/* files executable"
fi

export RUSTC_WRAPPER=sccache
pushd "$CI_DIR/.."
ci/lint.sh
ci/unit_tests.sh
ci/integration_tests.sh "$NODE_PARENT_DIR"
popd
