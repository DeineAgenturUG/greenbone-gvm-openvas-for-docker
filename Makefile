SHELL=/bin/bash
RELEASE="NO"
DL_DATA="NO"

all: BUILD_full

release: RELEASE="YES"
release: DL_DATA="YES"
release: BUILD_full

BUILD_light:
	RELEASE=${RELEASE} DL_DATA=${DL_DATA} BUILDX="buildx" BUILD_RELEASE_BASE="YES" ./local_multistep_build_v2.sh

BUILD_full:
	RELEASE=${RELEASE} DL_DATA=${DL_DATA} BUILDX="buildx" BUILD_RELEASE_BASE="YES" BUILD_BASE="YES" ./local_multistep_build_v2.sh

BUILD_data_only:
	RELEASE=${RELEASE} DL_DATA=${DL_DATA} BUILDX="buildx" ./local_multistep_build_v2.sh
