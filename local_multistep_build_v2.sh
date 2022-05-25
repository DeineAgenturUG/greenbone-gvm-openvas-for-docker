#!/usr/bin/env bash
set -Eeuo pipefail

TIMESTART="$(date '+%Y%m%d%H%M%S')"
GIT_SHA="$(git rev-parse --short=16 HEAD)"

BUILDER="${BUILDER:-default}"

DL_DATA="${DL_DATA:-NO}"

DIST="${DIST:-debian}"
DIST_FILE="${DIST}."

RELEASE="${RELEASE:-NO}"

BUILD_GVMD="${BUILD_GVMD:-YES}"
BUILD_OPENVAS="${BUILD_OPENVAS:-YES}"

BUILD_BASE="${BUILD_BASE:-NO}"
BUILD_RELEASE_BASE="${BUILD_RELEASE_BASE:-NO}"

PWD="$(pwd)"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
CACHE_IMAGE="${DOCKER_ORG}/gvm"
CACHE_IMAGE_OPENVAS="${DOCKER_ORG}/openvas-scanner"
CACHE_BUILD_IMAGE="${DOCKER_ORG}/gvm-build"
if [ "x${RELEASE}" != "xYES" ]; then
  CACHE_IMAGE="${CACHE_IMAGE}-develop"
  CACHE_IMAGE_OPENVAS="${CACHE_IMAGE_OPENVAS}-develop"
  CACHE_BUILD_IMAGE="${CACHE_BUILD_IMAGE}-develop"
fi
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
PLATFORM="${PLATFORM:-linux/amd64}"
BUILDX="${BUILDX:-buildx}"
#ADD_OPTIONS=${ADD_OPTIONS:-"--cache-from type=local,mode=max,src=/tmp/docker --load"}
#ADD_OPTIONS=${ADD_OPTIONS:-"--push"}
ADD_OPTIONS=${ADD_OPTIONS:-"--pull --push --progress=plain"}

if [ ! -f "build-args.txt" ]; then
  echo "build-args.txt not found"
  exit 1
fi

cd "${SCRIPT_DIR}" || exit 1

#for PLATFORM in "${PLATFORMS[@]}"; do
if [[ "x${BUILD_GVMD}" == "xYES" ]]; then

  if [[ "x${BUILD_BASE}" == "xYES" ]]; then

    TARGET="build_base"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvm_libs"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsa"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsad"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvmd"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .
    #
    #    TARGET="build_openvas_smb"
    #    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    #    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
    #      $(
    #        # shellcheck disable=SC2030
    #        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
    #        echo $out
    #        out=""
    #      ) \
    #      --build-arg BUILDKIT_INLINE_CACHE=1 \
    #      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
    #      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
    #      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
    #      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
    #      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
    #      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    printf "\n\n\n---------------"
    echo "build_openvas_scanner"
    printf "\n\n\n---------------"
    TARGET="build_openvas_scanner"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

  fi

  if [[ "x${BUILD_RELEASE_BASE}" == "xYES" ]]; then

    TARGET="latest"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      --no-cache \
      -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

    TARGET="latest-full"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:latest" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

  fi

  if [ "x$DL_DATA" == "xYES" ]; then
    mkdir -p ./GVMDocker/gvm-sync-data/
    wget -O ./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz "https://vulndata.deineagentur.biz/data.tar.xz"
  fi

  TARGET="latest-data"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
    --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_IMAGE}:latest" \
    --cache-from "${CACHE_IMAGE}:latest-full" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
    -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

  TARGET="latest-data-full"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --build-arg "CACHE_IMAGE=${CACHE_IMAGE}" \
    --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_IMAGE}:latest" \
    --cache-from "${CACHE_IMAGE}:latest-full" \
    --cache-from "${CACHE_IMAGE}:latest-data" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
    -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

fi

#####################
### Build OpenVAS ###
#####################

if [[ "x${BUILD_OPENVAS}" == "xYES" ]]; then
  if [[ "x${BUILD_RELEASE_BASE}" == "xYES" ]]; then
    TARGET="latest"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./OpenVASDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg "CACHE_IMAGE=${CACHE_IMAGE_OPENVAS}" \
      --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE_OPENVAS}:${TARGET}" \
      --no-cache \
      -t "${CACHE_IMAGE_OPENVAS}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_IMAGE_OPENVAS}:${TARGET}" ./OpenVASDocker/

  fi

#  TARGET="latest-data"
#  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
#  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./OpenVASDocker/Dockerfiles/release_${TARGET}.${DIST_FILE}Dockerfile \
#    $(
#      # shellcheck disable=SC2030
#      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
#      echo $out
#      out=""
#    ) \
#    --build-arg BUILDKIT_INLINE_CACHE=1 \
#    --build-arg "CACHE_IMAGE=${CACHE_IMAGE_OPENVAS}" \
#    --build-arg "CACHE_BUILD_IMAGE=${CACHE_BUILD_IMAGE}" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
#    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
#    --cache-from "${CACHE_IMAGE_OPENVAS}:latest" \
#    --cache-from "${CACHE_IMAGE_OPENVAS}:${TARGET}" \
#    --no-cache \
#    -t "${CACHE_IMAGE_OPENVAS}:${TARGET}" ./OpenVASDocker/
fi
#done
echo y | docker buildx prune --all

TIMEEND="$(date '+%Y%m%d%H%M%S')"
echo "START: ${TIMESTART}"
echo "END: ${TIMEEND}"
