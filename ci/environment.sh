# source this file with arguments when you need to override the default toolchain location
TOOLCHAIN_HOME="$1"
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
if [[ "$JENKINS_VERSION" != "" ]]; then
  TOOLCHAIN_HOME="$HOME"
elif [[ "$1" != "" ]]; then
  TOOLCHAIN_HOME="$("$CI_DIR/../../ci/bashify_workspace.sh" "$TOOLCHAIN_HOME")"
  export CARGO_HOME="$TOOLCHAIN_HOME/toolchains/.cargo"
  export RUSTUP_HOME="$TOOLCHAIN_HOME/toolchains/.rustup"
  export PATH="$CARGO_HOME/bin:$PATH"
  chmod +x "$CARGO_HOME"/bin/* || echo "Couldn't make .cargo/bin files executable"
  find "$RUSTUP_HOME" -type f -ipath "*\/bin/*" -print0 |xargs -0 -I{} chmod +x "{}" || echo "Couldn't make .rustup/**/bin/* files executable"
fi