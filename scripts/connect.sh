#!/usr/bin/env bash
set -Eeuo pipefail

MASTER_PORT=${MASTER_PORT:-22}

SCANNER_ID=$(cat /data/scannerid)

autossh -N -T -i /data/ssh/key -o ExitOnForwardFailure=yes -o UserKnownHostsFile=/data/ssh/known_hosts -p $MASTER_PORT -R /sockets/$SCANNER_ID.sock:/data/ospd.sock gvm@$MASTER_ADDRESS
