#!/usr/bin/env bash
set -Eeuo pipefail

TIMESTART=$(date '+%Y%m%d%H%M%S')

BUILD_BASE=${BUILD_BASE:-NO}
BUILD_RELEASE_BASE=${BUILD_RELEASE_BASE:-NO}

PWD="$(pwd)"
DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
CACHE_IMAGE="${DOCKER_ORG}/gvm"
CACHE_BUILD_IMAGE="${DOCKER_ORG}/gvm-build"
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
PLATFORM=${PLATFORM:-linux/amd64}
BUILDX="${BUILDX:-}"
#ADD_OPTIONS=${ADD_OPTIONS:-"--cache-from type=local,mode=max,src=/tmp/docker --load"}
#ADD_OPTIONS=${ADD_OPTIONS:-"--push"}
ADD_OPTIONS=${ADD_OPTIONS:-"--pull --push --progress=auto"}

if [ ! -f "build-args.txt" ]; then
  echo "build-args.txt not found"
  exit 1
fi

cd "${PWD}" || exit

#for PLATFORM in "${PLATFORMS[@]}"; do
  if [[ "x${BUILD_BASE}" != "xNO" ]]; then

    TARGET="build_base"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvm_libs"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsa"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsad"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvmd"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_openvas_smb"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_openvas_scanner"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_ospd_openvas"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./Dockerfiles/${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

  fi
  if [[ "x${BUILD_RELEASE_BASE}" != "xNO" ]]; then

    TARGET="latest"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

    TARGET="latest-full"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.Dockerfile \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:build_base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:latest" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/


  fi

  TARGET="latest-data"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.Dockerfile \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
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
    -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

  TARGET="latest-data-full"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f ./GVMDocker/Dockerfiles/release_${TARGET}.Dockerfile \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
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
    -t "${CACHE_IMAGE}:${TARGET}" ./GVMDocker/

#done
echo y | docker buildx prune --all

TIMEEND=$(date '+%Y%m%d%H%M%S')
echo "START: ${TIMESTART}"
echo "END: ${TIMEEND}"
