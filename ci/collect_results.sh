#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
function sudo_ask() {
	case "$OSTYPE" in
		msys)
			$@
			;;
		Darwin | darwin* | linux*)
			sudo $@
			;;
	esac
}

function node_ui_logs_windows() {
    mkdir -p generated/node-ui/AppData/Local/Substratum
    mkdir -p generated/node-ui/AppData/Roaming/SubstratumNode
    mkdir -p generated/node-ui/AppData/Roaming/Electron
    cp -R "$HOME/AppData/Local/Substratum" generated/node-ui/AppData/Local/Substratum || echo "No logs from SubstratumNode"
    cp -R "$HOME/AppData/Roaming/SubstratumNode/logs" generated/node-ui/AppData/Roaming/SubstratumNode || echo "No Electron SubstratumNode logs"
    cp "$HOME/AppData/Roaming/SubstratumNode/log.log" generated/node-ui/AppData/Roaming/SubstratumNode || echo "No Electron SubstratumNode log"
    cp -R "$HOME/AppData/Roaming/Electron/logs" generated/node-ui/AppData/Roaming/Electron || echo "No Electron logs"
    cp -R "$HOME/AppData/Roaming/jasmine" generated/node-ui/AppData/Roaming/jasmine || echo "No jasmine logs"
}

function node_ui_logs_linux_macOS() {
    echo "Nothing yet...on the way..."
}

function node_ui_logs() {
    case "$OSTYPE" in
      msys)
        node_ui_logs_windows
        ;;
      Darwin | darwin*)
        node_ui_logs_linux_macOS
        ;;
      linux*)
        node_ui_logs_linux_macOS
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
node_ui_logs
sudo_ask tar -czvf generated.tar.gz generated/*
popd
