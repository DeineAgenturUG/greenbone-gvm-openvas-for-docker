#!/usr/bin/env bash
set -Eeuo pipefail
echo -n >build.amd64.log
echo -n >build.arm64.log

# Set the required variables
export BUILD_PATH="GVMDocker/"
export REGISTRY="docker.io"
export USER="deineagentur"
export IMAGE_NAME="gvm-develop"
export IMAGE_TAG="latest-data"

# Set your manifest name
export MANIFEST_NAME="${REGISTRY}-${USER}-${IMAGE_NAME}-${IMAGE_TAG}"

# Create a multi-architecture manifest
buildah manifest create "${MANIFEST_NAME}" >/dev/null 2>&1 || true

if ! [ -f "./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz" ]; then
  mkdir -p ./GVMDocker/gvm-sync-data/
  wget -O ./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz "https://vulndata.deineagentur.biz/data.tar.xz"
fi
mkdir -p /github/greenbone-storage/

buildah build -f "${BUILD_PATH}Dockerfiles/release_latest-data.debian.Dockerfile" \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "/github/greenbone-storage/:/opt/file_context/" \
  --manifest ${MANIFEST_NAME} \
  --platform linux/amd64 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation rootless \
  --network private \
  --build-arg "SETUP_ARCH=amd64" \
  --build-arg "CACHE_IMAGE=${REGISTRY}/${USER}/${IMAGE_NAME}" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" \
  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH}

buildah build -f "${BUILD_PATH}Dockerfiles/release_latest-data.debian.Dockerfile" \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "/github/greenbone-storage/:/opt/file_context/" \
  --manifest ${MANIFEST_NAME} \
  --platform linux/arm64 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation rootless \
  --network private \
  --build-arg "SETUP_ARCH=arm64" \
  --build-arg "CACHE_IMAGE=${REGISTRY}/${USER}/${IMAGE_NAME}" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" \
  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH}

buildah build -f "${BUILD_PATH}Dockerfiles/release_latest-data.debian.Dockerfile" \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "/github/greenbone-storage/:/opt/file_context/" \
  --manifest ${MANIFEST_NAME} \
  --platform linux/arm/v7 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation rootless \
  --network private \
  --build-arg "SETUP_ARCH=arm" \
  --build-arg "CACHE_IMAGE=${REGISTRY}/${USER}/${IMAGE_NAME}" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" \
  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH}

# Push the full manifest, with both CPU Architectures
buildah manifest push --all --rm \
  ${MANIFEST_NAME} \
  "docker://${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}"

# buildah build -f GVMDocker/Dockerfiles/release_latest-data.debian.Dockerfile -v "$(pwd)/GVMDocker/:/opt/context/" --uts private \
#   --userns container --isolation chroot --all-platforms \
#   --network private \
#   --build-arg "CACHE_IMAGE=deineagenturug/gvm" \
#   --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build" -t "testme:latest-data"
