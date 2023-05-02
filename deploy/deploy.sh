#!/usr/bin/env bash
set -e
set -o pipefail
APP_NAME=appearances-processor
PROJECT_ID=$GCLOUD_PROJECT
ROOT_DIR=$(cd $(dirname $0) && pwd)
SECRETS=${APP_NAME}-secrets

export IMAGE_TAG="${GITHUB_SHA:-}"
export GCR_IMAGE_NAME=gcr.io/${PROJECT_ID}/${APP_NAME}
export IMAGE_NAME=${GCR_IMAGE_NAME}:${IMAGE_TAG}

echo "GCR_IMAGE_NAME=$GCR_IMAGE_NAME"
echo "IMAGE_NAME=$IMAGE_NAME"
echo "IMAGE_TAG=$IMAGE_TAG"

cd $ROOT_DIR/..

#docker rmi $(docker images -a -q)
python3 -m pip freeze > requirements.txt

pack build -B heroku/builder:22 $APP_NAME

image_id=$(docker images -q $APP_NAME)
echo "the image is is ${image_id}"
docker run $image_id
exit 0
docker tag "${image_id}" $IMAGE_NAME
docker push $IMAGE_NAME
echo "pushing ${image_id} to $IMAGE_NAME "
echo "tagging ${GCR_IMAGE_NAME}"

cd $ROOT_DIR
APP_YAML=${ROOT_DIR}/deploy/processor.yaml
APP_SERVICE_YAML=${ROOT_DIR}/deploy/processor-service.yaml
rm -rf $SECRETS_FN
touch $SECRETS_FN
echo writing to "$SECRETS_FN "
cat <<EOF >${SECRETS_FN}
PODCAST_RMQ_ADDRESS=amqp://${BP_RABBITMQ_MANAGEMENT_USERNAME}:${BP_RABBITMQ_MANAGEMENT_PASSWORD}@${BP_RABBITMQ_MANAGEMENT_HOST}/${BP_RABBITMQ_MANAGEMENT_VHOST}
BP_MODE=${BP_MODE_LOWERCASE}
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_REGION=$AWS_REGION
EOF

echo "SECRETS==========="
echo $SECRETS_FN

cd $OD
kustomize edit set image $GCR_IMAGE_NAME=$IMAGE_NAME
kustomize build ${OD} | kubectl apply -f -



rm $SECRETS_FN