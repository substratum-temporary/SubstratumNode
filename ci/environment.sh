# source this when you need to setup your environment
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
if [[ "$JENKINS_VERSION" != "" ]]; then
  WORKSPACE="$HOME"
elif [[ "$1" != "" ]]; then
  WORKSPACE="$("$CI_DIR/../../ci/bashify_workspace.sh" "$1")"
  export CARGO_HOME="$WORKSPACE/toolchains/.cargo"
  export RUSTUP_HOME="$WORKSPACE/toolchains/.rustup"
  export PATH="$CARGO_HOME/bin:$PATH"
  chmod +x "$CARGO_HOME"/bin/* || echo "Couldn't make .cargo/bin files executable"
  find "$RUSTUP_HOME" -type f -ipath "*\/bin/*" -print0 |xargs -0 -I{} chmod +x "{}" || echo "Couldn't make .rustup/**/bin/* files executable"
fi