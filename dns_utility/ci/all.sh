#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ "$JENKINS_VERSION" != "" ]]; then
  DNS_UTILITY_PARENT_DIR="$1"
  WORKSPACE="$HOME"
else
  DNS_UTILITY_PARENT_DIR=""
  WORKSPACE="$("$CI_DIR/../../ci/bashify_workspace.sh" "$1")"
  export RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
  export CARGO_HOME="$WORKSPACE/toolchains/.cargo"
  PATH="$WORKSPACE/toolchains/.cargo/bin:$PATH"
  chmod +x "$WORKSPACE"/toolchains/.cargo/bin/* || echo "Couldn't make .cargo/bin files executable"
fi

export RUSTC_WRAPPER=sccache
pushd "$CI_DIR/.."
ci/lint.sh
ci/unit_tests.sh
ci/integration_tests.sh "$DNS_UTILITY_PARENT_DIR"
popd