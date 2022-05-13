#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
WORK_DIR=$(pwd)
set -Eeuo pipefail

BUILD_PGSQL="${BUILD_PGSQL:-Yes}"
BUILD_BASE="${BUILD_BASE:-Yes}"
BUILD_PACKAGE="${BUILD_PACKAGE:-Yes}"
BUILD_PACKAGE_DATA_ONLY="${BUILD_PACKAGE_DATA_ONLY:-No}"
WAIT_AFTER_POSTGRES="${WAIT_AFTER_POSTGRES:-No}"

START_DATE_ALL=$(date "+%Y-%m-%d %H:%M:%S")

buildah containers --format "{{.ContainerID}}" | xargs --no-run-if-empty buildah rm
echo y | podman system prune -a -f --volumes
echo y | docker system prune -a -f --volumes

if [ ! -d "/github/greenbone-storage/" ]; then

    mkdir -p "/github/greenbone-storage/aptcache/"
    mkdir -p "/github/greenbone-storage/_apt/"
    mkdir -p "/github/greenbone-storage/build_gsa/"
    mkdir -p "/github/greenbone-storage/repo/"
    chmod -R 777 "/github/greenbone-storage/"

fi

#docker run --privileged --rm tonistiigi/binfmt --install all
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

sleep 10

pids=() # bash array

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    # wait for all pids
    for pid in ${pids[*]}; do
        kill -15 $pid
    done
    exit
}

echo ">>>> START ALL: $(date "+%Y-%m-%d %H:%M:%S")"

if [ "x${BUILD_PGSQL}" == "xYes" ]; then
    "${SCRIPT_DIR}/00_build_postgres.sh"
    if [ "x${WAIT_AFTER_POSTGRES}" != "xNo" ]; then
        if [ ${WAIT_AFTER_POSTGRES} > 0 ]; then
        echo "WAIT ${WAIT_AFTER_POSTGRES} seconds!"
        sleep ${WAIT_AFTER_POSTGRES}
        echo "DONE: WAIT ${WAIT_AFTER_POSTGRES} seconds!"
        else
            read -n 1 -s -r -p "Press any key to continue"
        fi
    fi
fi

if [ "x${BUILD_BASE}" == "xYes" ]; then
    "${SCRIPT_DIR}/01_build_base.sh" &
    pids+=("$!")
    "${SCRIPT_DIR}/01_build_gsa.sh"

    # wait for all pids
    for pid in ${pids[*]}; do
        wait $pid
    done

    IMAGE_TAG=build_gvm_libs "${SCRIPT_DIR}/01_build_base.sh"

    echo "WAIT 30 seconds!"
    sleep 30
    echo "DONE: WAIT 30 seconds!"

    IMAGE_TAG=build_gsad "${SCRIPT_DIR}/01_build_base.sh" &
    pids+=("$!")
    IMAGE_TAG=build_gvmd "${SCRIPT_DIR}/01_build_base.sh" &
    pids+=("$!")
    IMAGE_TAG=build_openvas_scanner "${SCRIPT_DIR}/01_build_base.sh" &
    pids+=("$!")

    # wait for all pids
    for pid in ${pids[*]}; do
        wait $pid
    done
fi

if [ "x${BUILD_PACKAGE}" == "xYes" ]; then
    "${SCRIPT_DIR}/02_build_gvm.sh"

    IMAGE_TAG=latest-data "${SCRIPT_DIR}/02_build_gvm.sh" &
    pids+=("$!")
    IMAGE_TAG=latest-full "${SCRIPT_DIR}/02_build_gvm.sh"

    # wait for all pids
    for pid in ${pids[*]}; do
        wait $pid
    done

    IMAGE_TAG=latest-data-full "${SCRIPT_DIR}/02_build_gvm.sh"
elif [ "x${BUILD_PACKAGE_DATA_ONLY}" == "xYes" ]; then
    IMAGE_TAG=latest-data "${SCRIPT_DIR}/02_build_gvm.sh"
    IMAGE_TAG=latest-data-full "${SCRIPT_DIR}/02_build_gvm.sh"
fi
echo "DONE!"
echo "<<<< START ALL: $START_DATE_ALL"
echo ">>>> END ALL: $(date "+%Y-%m-%d %H:%M:%S")"
