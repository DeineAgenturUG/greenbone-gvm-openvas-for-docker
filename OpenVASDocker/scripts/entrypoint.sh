#!/usr/bin/env bash
set -Eeuo pipefail

export SUPVISD=${SUPVISD:-supervisorctl}
export TZ=${TZ:-UTC}
export MASTER_PORT=${MASTER_PORT:-22}
export MASTER_ADDRESS=${MASTER_ADDRESS}
export AUTOSSH_DEBUG=${AUTOSSH_DEBUG:-0}
export AUTOSSH_LOGLEVEL=${AUTOSSH_DEBUG:-7}
export AUTOSSH_LOGFILE=/var/log/gvm/ssh-connection.log
export SCANNER_ID

if [ -z "${MASTER_ADDRESS}" ]; then
    echo "ERROR: The environment variable \"MASTER_ADDRESS\" is not set"
    exit 1
fi

if [ ! -d /var/lib/gvm/.ssh ]; then
    mkdir -p /var/lib/gvm/.ssh
fi

if [ ! -f "/var/lib/gvm/.scannerid" ]; then
    echo "Generating scanner id..."
    set +e
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1 >/var/lib/gvm/.scannerid
    set -e
fi

SCANNER_ID=$(cat /var/lib/gvm/.scannerid)

echo "GVM Started but with > supervisor <"
if [ ! -f "/firstrun" ]; then
    echo "Running first start configuration..."

    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone

    touch /firstrun
    touch /var/log/gvm/ssh-connection.log
fi
if [ -f "/var/lib/gvm/.firststart" ]; then
    rm /var/lib/gvm/.firststart
    touch /var/lib/gvm/.secondstart
fi

exec "$@"
