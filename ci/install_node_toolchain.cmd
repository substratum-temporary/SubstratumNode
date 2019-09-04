REM Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

REM This script is necessary because Azure is handing the Windows agent the target "d:a1", which can't be
REM handled by bash. It does _not_ mean /d/a1; it means D:\[current directory of D:]\a1.
REM MICROSOOOOOOFT! Agh!
set CACHE_TARGET=%1

curl https://win.rustup.rs -sSf > %TEMP%\rustup-init.exe
%TEMP%\rustup-init.exe -y
"%USERPROFILE%\.cargo\bin\rustup" update
"%USERPROFILE%\.cargo\bin\rustup" component add rustfmt
"%USERPROFILE%\.cargo\bin\rustup" component add clippy
"%USERPROFILE%\.cargo\bin\cargo" install sccache

xcopy /s "%USERPROFILE%\.cargo" "%CACHE_TARGET%\.cargo"
