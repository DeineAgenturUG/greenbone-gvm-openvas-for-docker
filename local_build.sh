#!/usr/bin/env bash
set -Eeuo pipefail

PWD="$(pwd)"
DOCKER_ORG="${DOCKER_ORG:-deineagenturug}"
declare -a PLATFORMS
PLATFORMS=("linux/amd64" "linux/arm64")
BUILDX="${BUILDX:-}"
ADD_OPTIONS=${ADD_OPTIONS:-"--squash --cache-from type=local,src=/tmp/docker --cache-to type=local,dest=/tmp/docker --load"}

cd "${PWD}" || exit

for PLATFORM in "${PLATFORMS[@]}"; do
	docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile.debian $(for i in `cat build-args.txt`; do out+="--build-arg $i " ; done; echo $out;out="") -t "${DOCKER_ORG}"/gvm:debian -t "${DOCKER_ORG}"/gvm:debian-latest .
	docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile.debian $(for i in `cat build-args.txt`; do out+="--build-arg $i " ; done; echo $out;out="") --build-arg OPT_PDF=1  -t "${DOCKER_ORG}"/gvm:debian-full .
	docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile.debian $(for i in `cat build-args.txt`; do out+="--build-arg $i " ; done; echo $out;out="") --build-arg SETUP=1 -t "${DOCKER_ORG}"/gvm:debian-data .
	docker ${BUILDX} build --platform "${PLATFORM}" ${ADD_OPTIONS} -f Dockerfile.debian $(for i in `cat build-args.txt`; do out+="--build-arg $i " ; done; echo $out;out="") --build-arg SETUP=1 --build-arg OPT_PDF=1 -t "${DOCKER_ORG}"/gvm:debian-data-full .
 done
