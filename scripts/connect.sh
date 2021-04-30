#!/usr/bin/env bash
set -Eeuo pipefail

MASTER_PORT=${MASTER_PORT:-22}
export AUTOSSH_LOGLEVEL=7
export AUTOSSH_LOGFILE=/usr/local/var/log/gvm/ssh-connection.log

SCANNER_ID=$(cat /data/scannerid)

autossh -M 0 -N -T -i /data/ssh/key -o ExitOnForwardFailure=yes -o UserKnownHostsFile=/data/ssh/known_hosts -p $MASTER_PORT -R /sockets/$SCANNER_ID.sock:/data/ospd.sock gvm@$MASTER_ADDRESS
