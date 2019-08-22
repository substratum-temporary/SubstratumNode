#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

PARENT_DIR="$1"

# Remove this line to slow down the build
#export RUSTC_WRAPPER=sccache
export RUSTFLAGS="-D warnings -Anon-snake-case"

cd "${CI_DIR}/../multinode_integration_tests"
ci/all.sh "$PARENT_DIR"
