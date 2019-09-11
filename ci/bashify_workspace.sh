#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

if [[ "$1" == "" ]]; then
  TOOLCHAIN_HOME="$HOME"
else
  TOOLCHAIN_HOME=$(echo "$1" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|g')
fi

echo "$TOOLCHAIN_HOME"
