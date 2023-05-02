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
#
#python -m pip install --upgrade pip
#pip install pipenv
#pipenv install
#pipenv run
#pip freeze > requirements.txt
#cat requirements.txt
pack build -B heroku/builder:22 $APP_NAME
IMAGE_ID=$(docker images -q $APP_NAME)
echo "  $IMAGE_NAME :: $IMAGE_ID "
docker run $IMAGE_ID
docker tag "${IMAGE_ID}" $IMAGE_NAME
docker push $IMAGE_NAME
echo "pushing ${IMAGE_ID} to $IMAGE_NAME "
echo "tagging ${GCR_IMAGE_NAME}"
cd $ROOT_DIR
#APP_YAML=${ROOT_DIR}/deploy/processor.yaml
#APP_SERVICE_YAML=${ROOT_DIR}/deploy/processor-service.yaml
#rm -rf $SECRETS_FN
#touch $SECRETS_FN
#echo writing to "$SECRETS_FN "
#cat <<EOF >${SECRETS_FN}
#
#EOF
#
#
#cd $OD
#
#
#
#rm $SECRETS_FN