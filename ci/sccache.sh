#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

# Remove these three lines to slow down the build
which sccache || cargo install sccache || echo "Skipping sccache installation"
sccache --start-server || echo "sccache server already running"
export RUSTC_WRAPPER=sccache
