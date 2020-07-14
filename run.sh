#!/bin/bash

output=$HOME/out

export CREDENTIALS_JSON_FN=${HOME}/credentials.json
export TOKEN_FN=${HOME}/token.pickle
export OUTPUT_JSON_FN=$output/appearances.json

cd appearances-site-generator

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
cd ..

mkdir -p $output/clone  
git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/joshlong/joshlong.github.io-content.git $output/clone 
cd $output/clone  
cp $JSON_FN $output/clone
ls -la $JSON_FN
git add *
git commit -am "updated $FN @ $(date)"
git push