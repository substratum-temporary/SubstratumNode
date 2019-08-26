#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
#PARENT_DIR="$1"

echo "Preparing build"

"$CI_DIR/sccache.sh"
"$CI_DIR/format.sh"

"$CI_DIR/../node-ui/ci/setup.sh"
"$CI_DIR/../node-ui/ci/lint.sh"
