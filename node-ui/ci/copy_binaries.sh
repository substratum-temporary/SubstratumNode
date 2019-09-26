#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
NODE_EXECUTABLE="SubstratumNode"
DNS_EXECUTABLE="dns_utility"

if [[ "$OSTYPE" == "msys" ]]; then
  NODE_EXECUTABLEW="${NODE_EXECUTABLE}W.exe"
  NODE_EXECUTABLE="$NODE_EXECUTABLE.exe"
  DNS_EXECUTABLEW="${DNS_EXECUTABLE}w.exe"
  DNS_EXECUTABLE="$DNS_EXECUTABLE.exe"
fi

rm -rf "$CI_DIR/../src/static/binaries"
mkdir -p "$CI_DIR/../src/static/binaries"

cp "$CI_DIR/../../node/target/release/$NODE_EXECUTABLE" "$CI_DIR/../src/static/binaries/"
cp "$CI_DIR/../../dns_utility/target/release/$DNS_EXECUTABLE" "$CI_DIR/../src/static/binaries/"
if [[ "$OSTYPE" == "msys" ]]; then
  cp "$CI_DIR/../../node/target/release/$NODE_EXECUTABLEW" "$CI_DIR/../src/static/binaries/"
  cp "$CI_DIR/../../dns_utility/target/release/$DNS_EXECUTABLEW" "$CI_DIR/../src/static/binaries/"
fi

# verify Windows binaries can execute
if [[ "$OSTYPE" == "msys" ]]; then
  ls -l "$CI_DIR/../src/static/binaries/$NODE_EXECUTABLEW"
  "$CI_DIR/../src/static/binaries/$NODE_EXECUTABLEW" --dns-servers 1.0.0.1,1.1.1.1,9.9.9.9,8.8.8.8 --real-user 1001:1001:/home/substratum --ip 1.2.3.4 --neighbors "wsijSuWax0tMAiwYPr5dgV4iuKDVIm5/l+E9BYJjbSI:1.1.1.1:12345;4321" --earning-wallet 0xadc1853c7859369639eb414b6342b36288fe6092 --gas-price 1 --blockchain-service-url "https://127.0.0.1" --chain ropsten
  if [[ "$?" != "0" ]]; then
    echo "============ APPLICATION LOGS ============"
    wevtutil query-events Application /rd:true /count:10 /format:text
    echo "============ SECURITY LOGS ============"
    wevtutil query-events Security /rd:true /count:10 /format:text
  fi

  ls -l "$CI_DIR/../src/static/binaries/$DNS_EXECUTABLEW"
fi
