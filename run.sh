#!/bin/bash

set -e 

output=$HOME/out

export GIT_CLONE_DIR=$output/clone
export CREDENTIALS_JSON_FN=${HOME}/credentials.json
export TOKEN_FN=${HOME}/token.pickle
export OUTPUT_JSON_FN=$output/appearances.json

cd appearances-site-generator

export EXISTING_GIT_USERNAME=$( git config --global user.name  )
git config --global user.email "josh@joshlong.com"
git config --global user.name "Appearances Bot"

echo "$PICKLED_TOKEN" | base64 -d > ${TOKEN_FN}
echo "$CREDENTIALS_JSON" > ${CREDENTIALS_JSON_FN}


ls -la ${TOKEN_FN}
ls -la ${CREDENTIALS_JSON_FN}

echo "TOKEN_FN=$TOKEN_FN"
echo "OUTPUT_JSON_FN=$OUTPUT_JSON_FN"


rm -rf $output
mkdir -p $output 

pipenv install
pipenv run python main.py
echo "---"
cat $OUTPUT_JSON_FN
echo "---"
cd ..

mkdir -p $GIT_CLONE_DIR
git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/joshlong/joshlong.github.io-content.git $GIT_CLONE_DIR
cd $GIT_CLONE_DIR  
cp $OUTPUT_JSON_FN $GIT_CLONE_DIR/content/appearances.json
ls -la $OUTPUT_JSON_FN
git add *
git commit -am "updated $FN @ $(date)" && git push  || echo "It was not possible to commit the results. Perhaps nothing changed?" 
git config --global user.name "$EXISTING_GIT_USERNAME"
