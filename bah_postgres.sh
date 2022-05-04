#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WORK_DIR=$(pwd)
set -Eeuo pipefail

START_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo $START_DATE

buildah containers --format "{{.ContainerID}}" | xargs --no-run-if-empty buildah rm
echo y | podman system prune -a -f --volumes

# Set the required variables
export BUILD_PATH="./"
export REGISTRY="docker.io"
export USER="deineagentur"
export IMAGE_NAME="gvm-build"
export IMAGE_TAG="postgres"
export STORAGE_PATH="${STORAGE_PATH:-/github/greenbone-storage}"

# Set your manifest name
export MANIFEST_NAME="${REGISTRY}-${USER}-${IMAGE_NAME}-${IMAGE_TAG}"

BUILD_PATH=$(readlink -f "${WORK_DIR}/${BUILD_PATH}")

# Create a multi-architecture manifest
buildah manifest create "${MANIFEST_NAME}" >/dev/null 2>&1 || true

buildah build -f "${BUILD_PATH}Dockerfiles/bah_postgres.debian.Dockerfile" \
  --manifest ${MANIFEST_NAME} \
  --jobs 2 \
  --platform=linux/amd64,linux/arm64,linux/ppc64le,linux/mips64le,linux/s390x \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation oci \
  --network private \
  -v "${STORAGE_PATH}/_apt:/aptrepo:rw" \
  ${BUILD_PATH}

#buildah build -f "${BUILD_PATH}Dockerfiles/bah_postgres.debian.Dockerfile" \
#  --manifest ${MANIFEST_NAME} \
#  --jobs 3 \
#  --platform=linux/arm/v5,linux/386 \
#  --cap-add NET_ADMIN --cap-add NET_RAW \
#  --uts private --pull \
#  --userns container --isolation oci \
#  --network private \
#  -v "${STORAGE_PATH}/_apt:/aptrepo:rw" \
#  --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" ${BUILD_PATH}
#

echo "START: $START_DATE"
END_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "=> END: $END_DATE"
