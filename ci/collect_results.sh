#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
function sudo_ask() {
	case "$OSTYPE" in
		msys)
			"$@"
			;;
		Darwin | darwin* | linux*)
			sudo "$@"
			;;
	esac
}

function node_ui_logs_specific() {
    LOCAL="$1"
    ROAMING="$2"
    mkdir -p "generated/node-ui/$LOCAL/Substratum"
    mkdir -p "generated/node-ui/$ROAMING/SubstratumNode"
    mkdir -p "generated/node-ui/$ROAMING/Electron"
    cp -R "$HOME/$LOCAL/Substratum" "generated/node-ui/$LOCAL/Substratum" || echo "No logs from SubstratumNode"
    cp -R "$HOME/$ROAMING/SubstratumNode/logs" "generated/node-ui/$ROAMING/SubstratumNode" || echo "No Electron SubstratumNode logs"
    cp "$HOME/$ROAMING/SubstratumNode/log.log" "generated/node-ui/$ROAMING/SubstratumNode" || echo "No Electron SubstratumNode log"
    cp -R "$HOME/$ROAMING/Electron/logs" "generated/node-ui/$ROAMING/Electron" || echo "No Electron logs"
    cp -R "$HOME/$ROAMING/jasmine" "generated/node-ui/$ROAMING/jasmine" || echo "No jasmine logs"
}

function node_ui_logs_generic() {
    case "$OSTYPE" in
      msys)
        node_ui_logs_specific "AppData/Local" "AppData/Roaming"
        ;;
      Darwin | darwin*)
        echo "Nothing yet...on the way..."
        ;;
      linux*)
        echo "Nothing yet...on the way..."
        ;;
      *)
        echo "Unrecognized operating system $OSTYPE"
        exit 1
        ;;
    esac
}

mkdir -p "$CI_DIR/../results"
pushd "$CI_DIR/../results"
sudo_ask rm -rf generated
mkdir generated
sudo_ask cp -R ../node/generated generated/node || echo "No results from SubstratumNode"
cp -R ../dns_utility/generated generated/dns_utility || echo "No results from dns_utility"
cp -R ../multinode_integration_tests/generated generated/multinode_integration_tests || echo "No results from multinode integration tests"
cp -R ../node-ui/generated generated/node-ui || echo "No results from SubstratumNode UI"
cp -R ../node-ui/dist generated/dist || echo "No distributable binaries"
node_ui_logs_generic
sudo_ask tar -czvf generated.tar.gz generated/*
popd
