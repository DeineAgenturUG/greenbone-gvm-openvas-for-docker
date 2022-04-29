#!/usr/bin/env bash
set -Eeuo pipefail
echo -n >build.amd64.log
echo -n >build.arm64.log
# Set your manifest name
export MANIFEST_NAME="multiarch-latest-data"

# Set the required variables
export BUILD_PATH="GVMDocker/"
export REGISTRY="docker.io"
export USER="deineagentur"
export IMAGE_NAME="gvm-develop"
export IMAGE_TAG="latest-data"

# Create a multi-architecture manifest
buildah manifest create "${MANIFEST_NAME}"

if ! [ -f "./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz" ]; then
  mkdir -p ./GVMDocker/gvm-sync-data/
  wget -O ./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz "https://vulndata.deineagentur.biz/data.tar.xz"
fi
mkdir -p $(pwd)/storage_build/

buildah build -f "${BUILD_PATH}Dockerfiles/release_latest-data.debian.Dockerfile" \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "$(pwd)/storage_build/:/opt/file_context/" \
  --manifest ${MANIFEST_NAME} \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation rootless \
  --network private \
  --build-arg "CACHE_IMAGE=${REGISTRY}/${USER}/${IMAGE_NAME}" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" \
  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH} >build.amd64.log 2>&1

sleep 60

buildah build -f "${BUILD_PATH}Dockerfiles/release_latest-data.debian.Dockerfile" \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "$(pwd)/storage_build/:/opt/file_context/" \
  --manifest ${MANIFEST_NAME} \
  --arch arm64 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation rootless \
  --network private \
  --build-arg "CACHE_IMAGE=${REGISTRY}/${USER}/${IMAGE_NAME}" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" \
  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH} >build.arm64.log 2>&1

sleep 60

# Push the full manifest, with both CPU Architectures
buildah manifest push --all \
  ${MANIFEST_NAME} \
  "docker://${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}"

# buildah build -f GVMDocker/Dockerfiles/release_latest-data.debian.Dockerfile -v "$(pwd)/GVMDocker/:/opt/context/" --uts private \
#   --userns container --isolation chroot --all-platforms \
#   --network private \
#   --build-arg "CACHE_IMAGE=deineagenturug/gvm" \
#   --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build" -t "testme:latest-data"
