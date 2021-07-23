#!/usr/bin/env bash
set -Eeuo pipefail

export SUPVISD=${SUPVISD:-supervisorctl}
export TZ=${TZ:-UTC}
export MASTER_PORT=${MASTER_PORT:-22}
export MASTER_ADDRESS=${MASTER_ADDRESS}
export AUTOSSH_LOGLEVEL=7
export AUTOSSH_LOGFILE=/var/log/gvm/ssh-connection.log

if [ -z "${MASTER_ADDRESS}" ]; then
    echo "ERROR: The environment variable \"MASTER_ADDRESS\" is not set"
    exit 1
fi

if [ "$1" == "/usr/bin/supervisord" ]; then
    #  exec /start.sh
    echo "GVM Started but with > supervisor <"
    if [ ! -f "/firstrun" ]; then
        echo "Running first start configuration..."

        ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone

        touch /firstrun
        touch /var/log/gvm/ssh-connection.log
    fi
fi

exec "$@"
