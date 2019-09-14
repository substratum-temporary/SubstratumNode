#!/bin/bash -xev
# Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.
CI_DIR="$( cd "$( dirname "$0" )" && pwd )"
STATUS=$1

GENERATED_NAME="generated-$AGENT_JOBNAME"

pushd "$CI_DIR/../results"
rm -rf repo || echo "No leftover repo to delete"
git clone "https://substratum-temporary:$GITHUB_TOKEN@github.com/substratum-temporary/SubstratumNode-results.git" repo
cd repo
cp README.md README.md.old
if [[ "$SYSTEM_PULLREQUEST_SOURCEBRANCH" == "" ]]; then
  RESULTS_LABEL="$BUILD_SOURCEBRANCH"
else
  RESULTS_LABEL="$SYSTEM_PULLREQUEST_SOURCEBRANCH"
fi
NEW_LINE="* $(date -u) - $RESULTS_LABEL ($AGENT_JOBNAME) - $STATUS: [$GENERATED_NAME.tar.gz](https://github.com/substratum-temporary/SubstratumNode-results/blob/master/results/$RESULTS_LABEL/$GENERATED_NAME.tar.gz?raw=true)"
cat README.md.old | grep -v "$RESULTS_LABEL ($AGENT_JOBNAME)" > README.md.clean
cat README.md.clean | sed -e '/\(Results Marker\)/q' > README.md
echo "$NEW_LINE" >> README.md
cat README.md.clean | sed -n '/\(Results Marker\)/,$p' | tail -n+2 >> README.md

mkdir -p "results/$RESULTS_LABEL"
cp ../generated.tar.gz "results/$RESULTS_LABEL/$GENERATED_NAME.tar.gz"
git add README.md "results/$RESULTS_LABEL/$GENERATED_NAME.tar.gz"
git commit -m "Latest results for $RESULTS_LABEL $(AGENT_JOBNAME)"
git push

popd
