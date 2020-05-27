#!/bin/bash
set -xe

IMG_TEMP_TAG="temp-$$-${RANDOM}"
if [[ -z ${EB_VER} ]];then
	docker build -t easybuild/base:${IMG_TEMP_TAG} .
else
	docker build --build-arg=EB_VER=${EB_VER} -t easybuild/base:${IMG_TEMP_TAG} .
fi
IMG_TAG=$(docker inspect -f '{{.Config.Labels.easybuild_version}}' easybuild/base:${IMG_TEMP_TAG})
docker tag easybuild/base:${IMG_TEMP_TAG} easybuild/base:${IMG_TAG}
docker rmi easybuild/base:${IMG_TEMP_TAG}
