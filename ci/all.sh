#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
PARENT_DIR="$1"

ci/format.sh

# Remove these two lines to slow down the build
which sccache || cargo install sccache || echo "Skipping sccache installation"  # Should do significant work only once
sccache --start-server || echo "sccache server already running"
export RUSTC_WRAPPER=sccache
export RUSTFLAGS="-D warnings -Anon-snake-case"

echo "*********************************************************************************************************"
echo "***                                               NODE HEAD                                           ***"
cd "$CI_DIR/../node"
ci/all.sh "$PARENT_DIR"
echo "***                                               NODE TAIL                                           ***"
echo "*********************************************************************************************************"
echo "*********************************************************************************************************"
echo "***                                           DNS UTILITY HEAD                                        ***"
cd "$CI_DIR/../dns_utility"
ci/all.sh "$PARENT_DIR"
echo "***                                           DNS UTILITY TAIL                                        ***"
echo "*********************************************************************************************************"
echo "*********************************************************************************************************"
echo "***                                             NODE UI HEAD                                          ***"
cd "$CI_DIR/../node-ui"
ci/all.sh
echo "***                                             NODE UI TAIL                                          ***"
echo "*********************************************************************************************************"
