#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

cargo install sccache || echo "sccache already installed"
sccache --start-server || echo "sccache server already running"
