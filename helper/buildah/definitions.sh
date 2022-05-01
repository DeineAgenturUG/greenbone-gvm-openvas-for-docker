#!/usr/bin/env bash

#PLATFORMS="linux/amd64,linux/ppc64le,linux/arm64,linux/arm/v7,linux/s390x"
PLATFORMS="linux/amd64"

GIT_BRANCH="$(git symbolic-ref --short HEAD)"

IMAGE_BASE_GVM="docker.io/deineagenturug/gvm"
IMAGE_BASE_OPENVAS="docker.io/deineagenturug/openvas-scanner"
IMAGE_BUILD_BASE_GVM="${IMAGE_BASE_GVM}-build"
IMAGE_RELEASE_GVM="${IMAGE_BASE_GVM}"
IMAGE_RELEASE_OPENVAS="${IMAGE_BASE_GVM}"
IMAGE_DEVEL_GVM="${IMAGE_BASE_GVM}-devel"
IMAGE_DEVEL_OPENVAS="${IMAGE_BASE_GVM}-devel"