#!/usr/bin/env bash
# This script will only build or download the DEB packages for POSTGRESQL
# this are stored by default at /github/greenbone-storage/_apt/
# Dockerfile is used heavily from https://github.com/docker-library/postgres
# Dockerfile located: Dockerfiles/bah_postgres.debian.Dockerfile
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
WORK_DIR=$(pwd)
set -Eeuo pipefail

START_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Set the required variables
BUILD_PATH="./"
REGISTRY="docker.io"
ORGANISATION="${ORGANISATION:-deineagentur}"
IMAGE_NAME="gvm-build"
IMAGE_TAG="postgres"
STORAGE_PATH="${STORAGE_PATH:-/github/greenbone-storage}"

echo "START (${IMAGE_TAG}): $START_DATE"

# Set your manifest name
MANIFEST_NAME="${REGISTRY}-${ORGANISATION}-${IMAGE_NAME}-${IMAGE_TAG}"

BUILD_PATH=$(readlink -e "${WORK_DIR}/${BUILD_PATH}")
STORAGE_PATH=$(readlink -e "${STORAGE_PATH}")

if [ -z "$BUILD_PATH" ] || [ -z "$STORAGE_PATH" ]; then
  echo "BUILD_PATH or STORAGE_PATH not exist"
  exit 1
fi
if [ ! -f ${WORK_DIR}/build-args.txt ]; then
  echo "${WORK_DIR}/build-args.txt not found"
  exit 1
fi
if [ ! -f ${WORK_DIR}/build-args-versions.txt ]; then
  echo "${WORK_DIR}/build-args-versions.txt not found"
  exit 1
fi
# echo "----START: ${IMAGE_TAG}----"
# ( set -o posix ; set )
# echo "----END: ${IMAGE_TAG}----"
# exit 0

# Create a multi-architecture manifest
buildah manifest create "${MANIFEST_NAME}" >/dev/null 2>&1 || true

buildah build -f "${BUILD_PATH}/Dockerfiles/bah_${IMAGE_TAG}.debian.Dockerfile" \
  --manifest ${MANIFEST_NAME} \
  --jobs 3 --layers \
  --platform=linux/amd64,linux/arm64,linux/ppc64le,linux/mips64le,linux/s390x \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation oci \
  --network private --no-cache \
  --security-opt=apparmor=unconfined \
  --security-opt=seccomp=unconfined \
  --logfile "${WORK_DIR}/buildlog_${IMAGE_NAME}-${IMAGE_TAG}.log" \
  --squash \
  $(
    # shellcheck disable=SC2030
    for i in $(cat ${WORK_DIR}/build-args-versions.txt); do out+="--build-arg $i "; done
    echo $out
    out=""
  ) \
  $(
    # shellcheck disable=SC2030
    for i in $(cat ${WORK_DIR}/build-args.txt); do out+="--build-arg $i "; done
    echo $out
    out=""
  ) \
  -v "${STORAGE_PATH}/aptcache/:/var/cache/myapt/archives/:rw" \
  -v "${STORAGE_PATH}/_apt/:/aptrepo/:rw" \
  -v "${WORK_DIR}/:/opt/context-full/:ro" \
  -v "${STORAGE_PATH}/source:/source" \
  "${BUILD_PATH}/"

echo "START (${IMAGE_TAG}): $START_DATE"
END_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "=> END (${IMAGE_TAG}): $END_DATE"
