#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export BUILDER="default"
export DL_DATA="YES"
export ADD_OPTIONS=${ADD_OPTIONS:-"--pull --push --progress=plain --no-cache"}
export BUILDX="buildx"
export BUILD_BASE="YES"
export BUILD_RELEASE_BASE="YES"
export PLATFORM="linux/amd64"
exec "${SCRIPT_DIR}/../local_multistep_build_v2.sh"
