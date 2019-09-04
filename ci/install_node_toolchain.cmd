REM Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

set CACHE_TARGET=%1

curl https://win.rustup.rs -sSf > %TEMP%\rustup-init.exe
%TEMP%\rustup-init.exe -y
"%USERPROFILE%\.cargo\bin\rustup" update
"%USERPROFILE%\.cargo\bin\rustup" component add rustfmt
"%USERPROFILE%\.cargo\bin\rustup" component add clippy
"%USERPROFILE%\.cargo\bin\cargo" install sccache

xcopy /s "%USERPROFILE%\.cargo" "%CACHE_TARGET%\.cargo"
