#!/usr/bin/env bash
set -Eeuo pipefail

if ! [ -f "./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz" ]; then
  mkdir -p ./GVMDocker/gvm-sync-data/
  wget -O ./GVMDocker/gvm-sync-data/gvm-sync-data.tar.xz "https://vulndata.deineagentur.biz/data.tar.xz"
fi
mkdir -p $(pwd)/storage_build/

buildah build -f GVMDocker/Dockerfiles/release_latest-data.debian.Dockerfile \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "$(pwd)/storage_build/:/opt/file_context/" \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private \
  --userns container --isolation chroot \
  --network private \
  --userns-uid-map=0:10000:65536 \
  --userns-gid-map=0:10000:65536 \
  --build-arg "CACHE_IMAGE=deineagenturug/gvm-develop" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" -t "testme:latest-data"

buildah rm gvm-develop-working-container

buildah build -f GVMDocker/Dockerfiles/release_latest-data.debian.Dockerfile \
  -v "$(pwd)/GVMDocker/:/opt/context/" \
  -v "$(pwd)/GVMDocker/scripts/:/opt/setup/scripts/" \
  -v "$(pwd)/storage_build/:/opt/file_context/" \
  --arch arm64 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  --uts private \
  --userns container --isolation chroot \
  --network private \
  --userns-uid-map=0:10000:65536 \
  --userns-gid-map=0:10000:65536 \
  --build-arg "CACHE_IMAGE=deineagenturug/gvm-develop" \
  --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build-develop" -t "testme:latest-data"

buildah rm gvm-develop-working-container

# buildah build -f GVMDocker/Dockerfiles/release_latest-data.debian.Dockerfile -v "$(pwd)/GVMDocker/:/opt/context/" --uts private \
#   --userns container --isolation chroot --all-platforms \
#   --network private \
#   --build-arg "CACHE_IMAGE=deineagenturug/gvm" \
#   --build-arg "CACHE_BUILD_IMAGE=deineagenturug/gvm-build" -t "testme:latest-data"
