#!/usr/bin/env bash
set -e
set -o pipefail
APP_NAME=appearances-processor
PROJECT_ID=bootiful
ROOT_DIR=$(cd $(dirname $0) && pwd)
SECRETS=${APP_NAME}-secrets

export IMAGE_TAG="${GITHUB_SHA:-${RANDOM}}"
export GCR_IMAGE_NAME=gcr.io/${PROJECT_ID}/${APP_NAME}
export IMAGE_NAME=${GCR_IMAGE_NAME}:${IMAGE_TAG}

echo "GCR_IMAGE_NAME=$GCR_IMAGE_NAME"
echo "IMAGE_NAME=$IMAGE_NAME"
echo "IMAGE_TAG=$IMAGE_TAG"

cd $ROOT_DIR/..

pack build -B heroku/builder:22 $APP_NAME
IMAGE_ID=$(docker images -q $APP_NAME)
echo " $IMAGE_NAME :: $IMAGE_ID "
docker run $IMAGE_ID
docker tag "${IMAGE_ID}" $IMAGE_NAME
docker push $IMAGE_NAME
echo "pushing ${IMAGE_ID} to $IMAGE_NAME "
echo "tagging ${GCR_IMAGE_NAME}"
cd $ROOT_DIR

python -c "import sys;print( open('processor.yaml','r').read().replace( 'IMG_NAME', '$IMAGE_NAME' ))" > final.yaml

SECRETS_FN=secrets.yaml
rm -rf $SECRETS_FN
touch $SECRETS_FN
export SECRETS=${APP_NAME}-secrets

export CREDENTIALS_JSON_FN=$HOME/credentials.json
export AUTHENTICATED_CREDENTIALS_JSON_FN=$HOME/authenticated-credentials.json
export OUTPUT=$HOME/out
export GIT_CLONE_DIR=$OUTPUT/clone
export OUTPUT_JSON_FN=$OUTPUT/appearances.json

cat <<EOF >${SECRETS_FN}
A=hello A
B=HIIIIIB
EOF
kubectl create secret generic $SECRETS --from-file=${SECRETS_FN}
kubectl apply -f final.yaml
