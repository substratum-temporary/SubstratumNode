#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
DNS_UTILITY_PARENT_DIR="$1"

if [[ "$DNS_UTILITY_PARENT_DIR" == "" ]]; then
    DNS_UTILITY_PARENT_DIR="$CI_DIR/../.."
fi

if [[ "$JENKINS_VERSION" != "" ]]; then
  WORKSPACE="$HOME"
else
  WORKSPACE="$("$CI_DIR/../../ci/bashify_workspace.sh" "$1")"
  export CARGO_HOME="$WORKSPACE/toolchains/.cargo"
  export RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
  export PATH="$CARGO_HOME/bin:$PATH"
  chmod +x "$CARGO_HOME"/bin/* || echo "Couldn't make .cargo/bin files executable"
  find "$RUSTUP_HOME" -type f -ipath "*\/bin/*" -print0 |xargs -0 -I{} chmod +x "{}" || echo "Couldn't make .rustup/**/bin/* files executable"
fi

pushd "$CI_DIR/.."
case "$OSTYPE" in
    msys)
        echo "Windows"
        ci/run_integration_tests.sh sudo
        ci/run_integration_tests.sh user
        ;;
    Darwin | darwin*)
        echo "macOS"
        sudo -E ci/run_integration_tests.sh sudo
        ci/run_integration_tests.sh user
        ;;
    linux-gnu)
        echo "Linux"
        sudo -E ci/run_integration_tests.sh sudo
        ci/run_integration_tests.sh user
        ;;
    *)
        exit 1
        ;;
esac
popd
