#!/bin/bash



cd appearances-site-generator
git config --global user.email "josh@joshlong.com"
git config --global user.name "Appearances Bot"
echo "$PICKLED_TOKEN" | base64 -d >token.pickle
echo "$CREDENTIALS_JSON" >credentials.json

output=$HOME/out
JSON_FN=$output/appearances.json
rm -rf $output
mkdir -p $output 

pipenv install
pipenv run python main.py  
cd ..

mkdir -p $output/clone  
git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/spring-tips/spring-tips.github.io.git $output/clone 
cd $output/clone  
cp $JSON_FN $output/clone
ls -la 
ls -la $JSON_FN
git add *
git commit -am "updated $FN @ $(date)"
git push