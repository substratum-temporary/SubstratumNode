#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
TOOLCHAIN_HOME="$1"
NODE_EXECUTABLE="SubstratumNode"
DNS_EXECUTABLE="dns_utility"
GPG_EXECUTABLE="gpg"

if [[ "$PASSPHRASE" == "" ]]; then
  echo "PASSPHRASE cannot be blank"
  exit 1
fi

if [[ "$OSTYPE" == "msys" ]]; then
  NODE_EXECUTABLEW="${NODE_EXECUTABLE}W.exe"
  NODE_EXECUTABLE="$NODE_EXECUTABLE.exe"
  DNS_EXECUTABLEW="${DNS_EXECUTABLE}W.exe"
  DNS_EXECUTABLE="$DNS_EXECUTABLE.exe"
  GPG_EXECUTABLE="/c/Program Files (x86)/gnupg/bin/gpg"
fi

source "$CI_DIR"/environment.sh "$TOOLCHAIN_HOME"

cd "$CI_DIR/../node"
cargo clean
"ci/build.sh"

cd "$CI_DIR/../dns_utility"
cargo clean
"ci/build.sh"

# sign
case "$OSTYPE" in
   linux*)
      cd "$CI_DIR/../node"
      "${GPG_EXECUTABLE}" --batch --passphrase "$PASSPHRASE" -b target/release/$NODE_EXECUTABLE
      "${GPG_EXECUTABLE}" --verify target/release/$NODE_EXECUTABLE.sig target/release/$NODE_EXECUTABLE
      cd "$CI_DIR/../dns_utility"
      "${GPG_EXECUTABLE}" --batch --passphrase "$PASSPHRASE" -b target/release/$DNS_EXECUTABLE
      "${GPG_EXECUTABLE}" --verify target/release/$DNS_EXECUTABLE.sig target/release/$DNS_EXECUTABLE
      ;;
   darwin*)
      security unlock-keychain -p "$PASSPHRASE"
      cd "$CI_DIR/../node"
      cp Info.plist target/release
      codesign -s 'Developer ID Application: Substratum Services, Inc. (TKDGR66924)'  -fv "target/release/$NODE_EXECUTABLE"
      codesign -v -v "target/release/$NODE_EXECUTABLE"
      cd "$CI_DIR/../dns_utility"
      cp Info.plist target/release
      codesign -s 'Developer ID Application: Substratum Services, Inc. (TKDGR66924)'  -fv "target/release/$DNS_EXECUTABLE"
      codesign -v -v "target/release/$DNS_EXECUTABLE"
      ;;
   msys)
      cd "$CI_DIR/../node"
      signtool sign //tr http://timestamp.digicert.com //td sha256 //fd sha256 //i "DigiCert SHA2 Assured ID Code Signing CA" //n "Substratum Services, Inc." //sm "target/release/$NODE_EXECUTABLE"
      signtool verify //pa "target/release/$NODE_EXECUTABLE"
      signtool sign //tr http://timestamp.digicert.com //td sha256 //fd sha256 //i "DigiCert SHA2 Assured ID Code Signing CA" //n "Substratum Services, Inc." //sm "target/release/$NODE_EXECUTABLEW"
      signtool verify //pa "target/release/$NODE_EXECUTABLEW"
      cd "$CI_DIR/../dns_utility"
      signtool sign //tr http://timestamp.digicert.com //td sha256 //fd sha256 //i "DigiCert SHA2 Assured ID Code Signing CA" //n "Substratum Services, Inc." //sm "target/release/$DNS_EXECUTABLE"
      signtool verify //pa "target/release/$DNS_EXECUTABLE"
      signtool sign //tr http://timestamp.digicert.com //td sha256 //fd sha256 //i "DigiCert SHA2 Assured ID Code Signing CA" //n "Substratum Services, Inc." //sm "target/release/$DNS_EXECUTABLEW"
      signtool verify //pa "target/release/$DNS_EXECUTABLEW"
      ;;
   *)
        echo "unsupported operating system detected."; exit 1
   ;;
esac

# gui
cd "$CI_DIR/../node-ui"
"ci/release.sh"

cd "$CI_DIR/../"

case "$OSTYPE" in
   linux*)
        zip -j SubstratumNode-Linux64-binary.zip dns_utility/target/release/$DNS_EXECUTABLE node/target/release/$NODE_EXECUTABLE node/target/release/$NODE_EXECUTABLE.sig
        zip -j SubstratumNode-Linux64-deb.zip node-ui/electron-builder-out/SubstratumNode*.deb
        ;;
   darwin*)
        zip -j SubstratumNode-macOS-binary.zip dns_utility/target/release/$DNS_EXECUTABLE node/target/release/$NODE_EXECUTABLE node/target/release/$NODE_EXECUTABLE.sig
        zip -j SubstratumNode-macOS.dmg.zip node-ui/electron-builder-out/SubstratumNode*.dmg
        ;;
   msys)
        signtool sign //tr http://timestamp.digicert.com //td sha256 //fd sha256 //i "DigiCert SHA2 Assured ID Code Signing CA" //n "Substratum Services, Inc." //sm "node-ui/electron-builder-out/SubstratumNode*.exe"
        signtool verify //pa "node-ui/electron-builder-out/SubstratumNode*.exe"

        ARCHIVE_PATH="$PWD"
        pushd dns_utility/target/release
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows-binary.zip $DNS_EXECUTABLE
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows-binary.zip $DNS_EXECUTABLEW
        popd
        pushd node/target/release
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows-binary.zip $NODE_EXECUTABLEW
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows-binary.zip $NODE_EXECUTABLE.sig
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows-binary.zip $NODE_EXECUTABLEW.sig
        popd
        pushd node-ui/electron-builder-out
        7z a "$ARCHIVE_PATH"/SubstratumNode-Windows.exe.zip SubstratumNode*.exe
        popd
        ;;
   *)
        echo "unsupported operating system detected."; exit 1
        ;;
esac
