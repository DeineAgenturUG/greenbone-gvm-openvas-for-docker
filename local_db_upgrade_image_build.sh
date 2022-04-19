#!/usr/bin/env bash
set -Eeuo pipefail

TIMESTART="$(date '+%Y%m%d%H%M%S')"

DEFAULT_PATH="./helper/db_upgrade/"

DIST="${DIST:-debian}"
DIST_FILE="${DIST}."

RELEASE="${RELEASE:-NO}"

BUILD_BASE="${BUILD_BASE:-NO}"
BUILD_RELEASE_BASE="${BUILD_RELEASE_BASE:-NO}"

PWD="$(pwd)"
DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
CACHE_IMAGE="${DOCKER_ORG}/pgdb-upgrade"
if [ "x${RELEASE}" != "xYES" ]; then
  CACHE_IMAGE="${CACHE_IMAGE}-develop"
fi
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
PLATFORM="${PLATFORM:-linux/amd64}"
BUILDX="${BUILDX:-buildx}"
ADD_OPTIONS=${ADD_OPTIONS:-"--pull --push --progress=plain"}

cd "${PWD}" || exit

  TARGET="latest"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f "${DEFAULT_PATH}Dockerfiles/release_db_upgrade.debian.Dockerfile" \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}" "${DEFAULT_PATH}"

#done
echo y | docker buildx prune --all

TIMEEND="$(date '+%Y%m%d%H%M%S')"
echo "START: ${TIMESTART}"
echo "END: ${TIMEEND}"
