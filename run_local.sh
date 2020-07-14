cd google-sheet-ingest
files=$HOME/Dropbox/spring-tips/spring-tips-sheet/secure/
export PICKLED_TOKEN=$(cat $files/token.pickle | base64)
export CREDENTIALS_JSON=$(cat $files/credentials.json)

echo "$PICKLED_TOKEN" | base64 -d >token.pickle
echo "$CREDENTIALS_JSON" >credentials.json

output=$HOME/Desktop/out
export JSON_FN=$output/output.json
export RSS_FN=$output/output.rss

pipenv install 
pipenv run python main.py  

rm token.pickle 
rm credentials.json 

cd ..
source $files/git.sh 



rm -rf $output


git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/spring-tips/spring-tips.github.io.git $output 
cd $output 
git add *
git commit -am "updated $FN @ $(date)"
git push