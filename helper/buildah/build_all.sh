#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
WORK_DIR=$(pwd)
set -Eeuo pipefail

START_DATE_ALL=$(date "+%Y-%m-%d %H:%M:%S")

buildah containers --format "{{.ContainerID}}" | xargs --no-run-if-empty buildah rm
echo y | podman system prune -a -f --volumes

sleep 10

pids=()  # bash array

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

"${SCRIPT_DIR}/00_build_postgres.sh"
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

echo "DONE!"
echo "<<<< START ALL: $START_DATE_ALL"
echo ">>>> END ALL: $(date "+%Y-%m-%d %H:%M:%S")"