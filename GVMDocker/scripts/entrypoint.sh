#!/usr/bin/env bash
set -Eeuo pipefail
# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

source "${SCRIPT_DIR}/addons/00_proxy.sh"
source "${SCRIPT_DIR}/addons/01_env.sh"
source "${SCRIPT_DIR}/addons/02_nullmailer.sh"

if [ "$1" == "/usr/bin/supervisord" ]; then

    cp /opt/setup/config/supervisord.conf /etc/supervisord.conf
    cp /opt/setup/config/logrotate-gvm.conf /etc/logrotate.d/gvm
    mkdir -p /etc/redis/
    cp /opt/setup/config/redis-openvas.conf /etc/redis/redis-openvas.conf
    cp /opt/setup/config/sshd_config /etc/ssh/sshd_config

    #  exec /start.sh
    echo "GVM Started but with > supervisor <"
    if [ ! -f "/firstrun" ]; then
        echo "Running first start configuration..."

        ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone

        touch /firstrun
    fi
fi

exec "$@"
