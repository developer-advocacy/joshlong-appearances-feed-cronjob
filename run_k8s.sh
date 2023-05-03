#!/bin/bash
set -e
#
# this is the entry point within the container. it's what
# actually starts up the process. it has access to the
# environment furnished by the secrets
#
# TODO we need the following four variables passed in from the CI environment:
# TODO AUTHENTICATED_CREDENTIALS_JSON, CREDENTIALS_JSON, SHEET_ID
##

export CREDENTIALS_JSON_FN=$HOME/credentials.json
export AUTHENTICATED_CREDENTIALS_JSON_FN=$HOME/authenticated-credentials.json
export OUTPUT=$HOME/out
export GIT_CLONE_DIR=$OUTPUT/clone
export OUTPUT_JSON_FN=$OUTPUT/appearances.json

echo "${AUTHENTICATED_CREDENTIALS_JSON}" | base64 -d >$AUTHENTICATED_CREDENTIALS_JSON_FN
echo "${CREDENTIALS_JSON}" | base64 -d >$CREDENTIALS_JSON_FN

rm -rf $OUTPUT
mkdir -p $OUTPUT

python main.py

git || echo "git needs to be installed"

cat $OUTPUT_JSON_FN

echo "TODO: save this to the git repository somehow"

export EXISTING_GIT_USERNAME=$(git config --global user.name)
git config --global user.email "josh@joshlong.com"
git config --global user.name "Appearances Bot"
mkdir -p $GIT_CLONE_DIR
git clone https://${GIT_USERNAME}:${GH_PAT}@github.com/joshlong/joshlong.github.io-content.git $GIT_CLONE_DIR
cd $GIT_CLONE_DIR
cp $OUTPUT_JSON_FN $GIT_CLONE_DIR/content/appearances.json
ls -la $OUTPUT_JSON_FN
git add *
git commit -am "updated $FN @ $(date)" && git push  || echo "It was not possible to commit the results. Perhaps nothing changed?"
git config --global user.name "$EXISTING_GIT_USERNAME"
#
#sleep 3m  # give the cached http urls in github time to invalidate their caches so when we get to the next step, were not pulling down cached URIs
#
#curl -H "Accept: application/vnd.github.everest-preview+json" -H "Authorization: token ${GH_PAT}" --request POST  --data '{"event_type": "update-event"}' https://api.github.com/repos/developer-advocacy/appearances-processor/dispatches
#echo "the appearances-processor has finished. Triggered an update-event for the feed-processor to revise the HTML."
