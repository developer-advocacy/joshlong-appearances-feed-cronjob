#!/usr/bin/env bash
set -e
set -o pipefail

cd $GITHUB_WORKSPACE
echo "starting the build in $(pwd) "
APP_NAME=joshlong-appearances-feed-cronjob
SECRETS=${APP_NAME}-secrets
PROJECT_ID=${GCLOUD_PROJECT}
IMAGE_NAME=gcr.io/${PROJECT_ID}/${APP_NAME}
echo "IMAGE_NAME=$IMAGE_NAME"
pack build  $IMAGE_NAME  -B heroku/builder:22
docker push $IMAGE_NAME

SECRETS_FN=secrets.yaml
SECRETS=${APP_NAME}-secrets
rm -rf $SECRETS_FN
touch $SECRETS_FN

CREDENTIALS_JSON_FN=$HOME/credentials.json
AUTHENTICATED_CREDENTIALS_JSON_FN=$HOME/authenticated-credentials.json
OUTPUT=$HOME/out
GIT_CLONE_DIR=$OUTPUT/clone
OUTPUT_JSON_FN=$OUTPUT/appearances.json

cat <<EOF >${SECRETS_FN}
AUTHENTICATED_CREDENTIALS_JSON=${AUTHENTICATED_CREDENTIALS_JSON}
SHEET_ID=${SHEET_ID}
CREDENTIALS_JSON=${CREDENTIALS_JSON}
GIT_USERNAME=${GIT_USERNAME}
GH_PAT=${GH_PAT}
EOF
cat $SECRETS_FN
kubectl delete secrets/$SECRETS || echo "could not delete the secrets for $SECRETS "
kubectl create secret generic $SECRETS --from-env-file $SECRETS_FN
echo created secrets

kubectl delete -f deploy/processor.yaml  || echo "could not delete existing deployment as there is probably nothing to delete in the first place."
kubectl apply  -f deploy/processor.yaml

# lets kick it off at least the first time and then it'll just run every hour.
kubectl create job --from=cronjob/${APP_NAME} ${APP_NAME}-cronjob-run-$RANDOM
