#!/bin/bash
set -xe

ORG="easybuilders"
REPO="base"
OS="centos7"

IMG_TEMP_TAG="temp-$$-${RANDOM}"
if [[ -z ${EB_VER} ]];then
	docker build -f Dockerfile.${REPO}-${OS} -t ${ORG}/${REPO}:${IMG_TEMP_TAG} .
else
	docker build -f Dockerfile.${REPO}-${OS} --build-arg=EB_VER=${EB_VER} -t ${ORG}/${REPO}:${IMG_TEMP_TAG} .
fi

# determine final tag using EasyBuild version used in container
IMG_TAG=${OS}-eb$(docker inspect -f '{{.Config.Labels.easybuild_version}}' ${ORG}/${REPO}:${IMG_TEMP_TAG})
docker tag ${ORG}/${REPO}:${IMG_TEMP_TAG} ${ORG}/${REPO}:${IMG_TAG}
docker rmi ${ORG}/${REPO}:${IMG_TEMP_TAG}
