#!/usr/bin/env bash
set -Eeuo pipefail

TIMESTART=$(date +%y%m%d%H%M%S)


PREBUILD=${PREBUILD:-NO}
POSTBUILD=${POSTBUILD:-NO}

PWD="$(pwd)"
DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
CACHE_IMAGE="${DOCKER_ORG}/gvm"
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
BUILDX="${BUILDX:-}"
#ADD_OPTIONS=${ADD_OPTIONS:-"--cache-from type=local,mode=max,src=/tmp/docker --load"}
#ADD_OPTIONS=${ADD_OPTIONS:-"--push"}
ADD_OPTIONS=${ADD_OPTIONS:-"--push --progress=plain"}

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
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

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
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

  fi
  if [[ "x${POSTBUILD}" != "xNO" ]]; then

    TARGET="debian-latest"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_IMAGE}:build_gsa" \
      --cache-from "${CACHE_IMAGE}:build_gsad" \
      --cache-from "${CACHE_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:build_ospd_openvas" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .

    TARGET="debian-latest-full"
    # shellcheck disable=SC2046,SC2086,SC2013,SC2031
    docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
      $(
        # shellcheck disable=SC2030
        for i in $(cat build-args.txt); do out+="--build-arg $i "; done
        echo $out
        out=""
      ) \
      --build-arg OPT_PDF=1 \
      --cache-from "${CACHE_IMAGE}:base" \
      --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
      --cache-from "${CACHE_IMAGE}:build_gvmd" \
      --cache-from "${CACHE_IMAGE}:build_gsa" \
      --cache-from "${CACHE_IMAGE}:build_gsad" \
      --cache-from "${CACHE_IMAGE}:build_openvas_smb" \
      --cache-from "${CACHE_IMAGE}:build_openvas_scanner" \
      --cache-from "${CACHE_IMAGE}:build_ospd_openvas" \
      --cache-from "${CACHE_IMAGE}:debian-latest" \
      --cache-from "${CACHE_IMAGE}:${TARGET}" \
      -t "${CACHE_IMAGE}:${TARGET}" .


  fi

  TARGET="debian-latest-data"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg SETUP=1 \
    --cache-from "${CACHE_IMAGE}:base" \
    --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_IMAGE}:build_gsa" \
    --cache-from "${CACHE_IMAGE}:build_gsad" \
    --cache-from "${CACHE_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_IMAGE}:build_ospd_openvas" \
    --cache-from "${CACHE_IMAGE}:debian-latest" \
    --cache-from "${CACHE_IMAGE}:debian-latest-full" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}" .

  TARGET="debian-latest-data-full"
  # shellcheck disable=SC2046,SC2086,SC2013,SC2031
  docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile_multistep.debian \
    $(
      # shellcheck disable=SC2030
      for i in $(cat build-args.txt); do out+="--build-arg $i "; done
      echo $out
      out=""
    ) \
    --build-arg SETUP=1 --build-arg OPT_PDF=1 \
    --cache-from "${CACHE_IMAGE}:base" \
    --cache-from "${CACHE_IMAGE}:build_gvm_libs" \
    --cache-from "${CACHE_IMAGE}:build_gvmd" \
    --cache-from "${CACHE_IMAGE}:build_gsa" \
    --cache-from "${CACHE_IMAGE}:build_gsad" \
    --cache-from "${CACHE_IMAGE}:build_openvas_smb" \
    --cache-from "${CACHE_IMAGE}:build_openvas_scanner" \
    --cache-from "${CACHE_IMAGE}:build_ospd_openvas" \
    --cache-from "${CACHE_IMAGE}:debian-latest" \
    --cache-from "${CACHE_IMAGE}:debian-latest-full" \
    --cache-from "${CACHE_IMAGE}:debian-latest-data" \
    --cache-from "${CACHE_IMAGE}:${TARGET}" \
    -t "${CACHE_IMAGE}:${TARGET}" .

#done
echo y | docker buildx prune --all

TIMEEND=$(date +%y%m%d%H%M%S)
echo "START: ${TIMESTART}"
echo "END: ${TIMEEND}"
