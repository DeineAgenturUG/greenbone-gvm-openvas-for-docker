#!/usr/bin/env bash
set -Eeuo pipefail

TIMESTART=$(date '+%Y%m%d%H%M%S')

GIT_SHA="$(git rev-parse --short=16 HEAD)"

PREBUILD=${PREBUILD:-NO}
POSTBUILD=${POSTBUILD:-NO}

PWD="$(pwd)"
DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
CACHE_IMAGE="${DOCKER_ORG}/gvm"
CACHE_BUILD_IMAGE="${DOCKER_ORG}/gvm-build"
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
BUILDX="${BUILDX:-}"
#ADD_OPTIONS=${ADD_OPTIONS:-"--cache-from type=local,mode=max,src=/tmp/docker --load"}
#ADD_OPTIONS=${ADD_OPTIONS:-"--push"}
ADD_OPTIONS=${ADD_OPTIONS:-"--pull --push --progress=auto"}

cd "${PWD}" || exit

#for PLATFORM in "${PLATFORMS[@]}"; do
  if [[ "x${PREBUILD}" != "xNO" ]]; then

    TARGET="base"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvm_libs"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsa"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gsad"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_gvmd"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_openvas_smb"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_openvas_scanner"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

    TARGET="build_ospd_openvas"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:${TARGET}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_BUILD_IMAGE}:${TARGET}" .

  fi
  if [[ "x${POSTBUILD}" != "xNO" ]]; then

    TARGET="latest"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_ospd_openvas" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

    TARGET="latest-full"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${CACHE_BUILD_IMAGE}:base" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_BUILD_IMAGE}:build_ospd_openvas" \
      --cache-from "${CACHE_IMAGE}:latest" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
      -t "${CACHE_IMAGE}:${TARGET}" .


  fi

  TARGET="latest-data"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from "${CACHE_BUILD_IMAGE}:base" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_ospd_openvas" \
    --cache-from "${CACHE_IMAGE}:latest" \
    --cache-from "${CACHE_IMAGE}:latest-full" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
    -t "${CACHE_IMAGE}:${TARGET}" .

  TARGET="latest-data-full"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --target ${TARGET} --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from "${CACHE_BUILD_IMAGE}:base" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsa" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_gsad" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_BUILD_IMAGE}:build_ospd_openvas" \
    --cache-from "${CACHE_IMAGE}:latest" \
    --cache-from "${CACHE_IMAGE}:latest-full" \
    --cache-from "${CACHE_IMAGE}:latest-data" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}-${GIT_SHA}" \
    -t "${CACHE_IMAGE}:${TARGET}" .

#done
echo y | docker buildx prune --all

TIMEEND=$(date '+%Y%m%d%H%M%S')
echo "START: ${TIMESTART}"
echo "END: ${TIMEEND}"
