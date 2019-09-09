#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
#PARENT_DIR="$1"

echo "Path: $PATH"
find /home/vsts/.cargo/bin/ -type f
"$CI_DIR/format.sh"
