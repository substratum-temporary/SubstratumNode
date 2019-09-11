#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
WORKSPACE="$1"

pushd "$CI_DIR/.."
case "$OSTYPE" in
    msys)
        echo "Windows"
        ci/run_integration_tests.sh
        ;;
    Darwin | darwin*)
        echo "macOS"
        sudo ci/run_integration_tests.sh "$WORKSPACE"
        ;;
    linux-gnu)
        echo "Linux"
        sudo ci/run_integration_tests.sh "$WORKSPACE"
        ;;
    *)
        exit 1
        ;;
esac
popd
