#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "PATH: $PATH"
echo "which google-chrome: $(which google-chrome)"
echo "/usr/local/bin:"
ls -l /usr/local/bin/
pushd "$CI_DIR/.."
yarn ts-test
popd
