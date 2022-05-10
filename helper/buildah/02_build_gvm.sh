#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
WORK_DIR=$(pwd)
set -Eeuo pipefail
buildah containers --format "{{.ContainerID}}" | xargs --no-run-if-empty buildah rm
START_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Set the required variables
BUILD_PATH="./GVMDocker"
REGISTRY="docker.io"
ORGANISATION="${ORGANISATION:-deineagentur}"
IMAGE_NAME="gvm"
IMAGE_TAG="${IMAGE_TAG:-latest}"
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

buildah build -f "${BUILD_PATH}/Dockerfiles/bah_release_${IMAGE_TAG}.debian.Dockerfile" \
  --manifest ${MANIFEST_NAME} \
  --jobs 3 --layers \
  --platform=linux/amd64,linux/arm64,linux/ppc64le,linux/mips64le,linux/s390x \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private --pull \
  --userns container --isolation oci \
  --network private --no-cache \
  --http-proxy=false \
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
  -v "${STORAGE_PATH}/repo/:/aptrepo/:rw" \
  -v "${STORAGE_PATH}/aptcache/:/var/cache/myapt/:rw" \
  -v "${BUILD_PATH}/:/opt/context/:ro" \
  -v "${WORK_DIR}/:/opt/context-full/:ro" \
  -v "${STORAGE_PATH}/build_gsa/:/install_gsa:ro" \
  "${BUILD_PATH}/"

buildah tag "localhost/${MANIFEST_NAME}" "${REGISTRY}/${ORGANISATION}/${IMAGE_NAME}:${IMAGE_TAG}"
buildah manifest rm "localhost/${MANIFEST_NAME}"
buildah manifest push --all "${REGISTRY}/${ORGANISATION}/${IMAGE_NAME}:${IMAGE_TAG}" "docker://${REGISTRY}/${ORGANISATION}/${IMAGE_NAME}:${IMAGE_TAG}"
buildah manifest push --all "${REGISTRY}/${ORGANISATION}/${IMAGE_NAME}:${IMAGE_TAG}" "docker://${REGISTRY}/${ORGANISATION}/${IMAGE_NAME}:${IMAGE_TAG}-$(date "+%Y%m%d_%H%M")"

echo "START (${IMAGE_TAG}): $START_DATE"
END_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "=> END (${IMAGE_TAG}): $END_DATE"
