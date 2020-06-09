#!/bin/bash
set -xe

ORG="easybuilders"
REPO="test"
OS="centos7"
EB="eb4.2.1"
CPU_ARCH="haswell"

GCC="GCC-9.3.0"
FOSS="foss-2020a"
SCIPY_BUNDLE="SciPy-bundle-2020.03-foss-2020a-Python-3.8.2"
HDF5="HDF5-1.10.6-gompi-2020a"

COMMON_TAG=${ORG}/${REPO}:${OS}

# build base container
docker build -f Dockerfile.base-${OS} -t ${ORG}/base:${OS}-${EB} .
# build container for GCC-9.3.0 on Haswell
docker build -f Dockerfile.easybuild-${OS} --build-arg CPU_ARCH=${CPU_ARCH} --build-arg IMG_NAME=base --build-arg EASYCONFIG=${GCC}.eb -t ${COMMON_TAG}-${CPU_ARCH}-${GCC} .
# build container for foss-2020a on Haswell, on top of GCC-9.3.0 container
docker build -f Dockerfile.easybuild-${OS} --build-arg CPU_ARCH=${CPU_ARCH} --build-arg IMG_NAME=${REPO} --build-arg IMG_TAG=${OS}-${CPU_ARCH}-${GCC} --build-arg EASYCONFIG=${FOSS}.eb -t ${ORG}/${REPO}:${OS}-${CPU_ARCH}-${FOSS} .
# build software container with SciPy-bundle for Haswell, on top of foss-2020a container
docker build -f Dockerfile.easybuild-${OS} --build-arg CPU_ARCH=${CPU_ARCH} --build-arg IMG_NAME=${REPO} --build-arg IMG_TAG=${OS}-${CPU_ARCH}-${FOSS} --build-arg EASYCONFIG=${SCIPY_BUNDLE}.eb -t ${ORG}/${REPO}:${OS}-${CPU_ARCH}-${SCIPY_BUNDLE} .
# build software container with HDF5 for Haswell, on top of foss-2020a container
docker build -f Dockerfile.easybuild-${OS} --build-arg CPU_ARCH=${CPU_ARCH} --build-arg IMG_NAME=${REPO} --build-arg IMG_TAG=${OS}-${CPU_ARCH}-${SCIPY_BUNDLE} --build-arg EASYCONFIG=${HDF5}.eb -t ${ORG}/${REPO}:${OS}-${CPU_ARCH}-${HDF5} .

# build final tutorial image
docker build -f Dockerfile.easybuild-tutorial --build-arg CPU_ARCH=${CPU_ARCH} --build-arg IMG_NAME=${REPO} --build-arg IMG_TAG=${OS}-${CPU_ARCH}-${HDF5} -t ${ORG}/${REPO}:${OS}-${CPU_ARCH}-tutorial .
