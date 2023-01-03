#!/bin/bash
set -e

export CREDENTIALS_JSON_FN=$HOME/credentials.json
export AUTHENTICATED_CREDENTIALS_JSON_FN=$HOME/authenticated-credentials.json
export OUTPUT=$HOME/out
export GIT_CLONE_DIR=$OUTPUT/clone
export OUTPUT_JSON_FN=$OUTPUT/appearances.json

echo "${AUTHENTICATED_CREDENTIALS_JSON}" | base64 -d > $AUTHENTICATED_CREDENTIALS_JSON_FN
echo "${CREDENTIALS_JSON}" | base64 -d > $CREDENTIALS_JSON_FN

export EXISTING_GIT_USERNAME=$( git config --global user.name  )
git config --global user.email "josh@joshlong.com"
git config --global user.name "Appearances Bot"

rm -rf $OUTPUT
mkdir -p $OUTPUT

pip install pipenv
pipenv install
pipenv run python main.py

echo "---"
cat "$OUTPUT_JSON_FN"
echo "---"
cd ..

mkdir -p $GIT_CLONE_DIR
git clone https://${GIT_USERNAME}:${GH_PAT}@github.com/joshlong/joshlong.github.io-content.git $GIT_CLONE_DIR
cd $GIT_CLONE_DIR  
cp $OUTPUT_JSON_FN $GIT_CLONE_DIR/content/appearances.json
ls -la $OUTPUT_JSON_FN
git add *
git commit -am "updated $FN @ $(date)" && git push  || echo "It was not possible to commit the results. Perhaps nothing changed?" 
git config --global user.name "$EXISTING_GIT_USERNAME"


sleep 3m  # give the cached http urls in github time to invalidate their caches so when we get to the next step, were not pulling down cached URIs

curl -H "Accept: application/vnd.github.everest-preview+json" -H "Authorization: token ${GH_PAT}" --request POST  --data '{"event_type": "update-event"}' https://api.github.com/repos/developer-advocacy/appearances-processor/dispatches
echo "the appearances-processor has finished. Triggered an update-event for the feed-processor to revise the HTML."
