#!/usr/bin/env bash
set -Eeuo pipefail
export HTTP_PROXY="${HTTP_PROXY:-${http_proxy:-}}"
export HTTPS_PROXY="${HTTPS_PROXY:-${https_proxy:-}}"
export RSYNC_PROXY="${RSYNC_PROXY:-${rsync_proxy:-}}"
export NO_PROXY="${NO_PROXY:-${no_proxy:-}}"
if [[ -n "${HTTP_PROXY}" ]]; then
  touch /etc/apt/apt.conf.d/99proxy
  {
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";"
  } > /etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${HTTPS_PROXY}" ]]; then
  touch /etc/apt/apt.conf.d/99proxy
  {
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";"
  } >> /etc/apt/apt.conf.d/99proxy
fi

touch /opt/setup/.env
set -o allexport
# shellcheck disable=SC1091
source /opt/setup/.env
set +o allexport
export GVMD_USER=${USERNAME:-${GVMD_USER:-admin}}
export GVMD_PASSWORD=${PASSWORD:-${GVMD_PASSWORD:-adminpassword}}
export GVMD_PASSWORD_FILE=${PASSWORD_FILE:-${GVMD_PASSWORD_FILE:-adminpassword}}
export GVMD_HOST=${GVMD_HOST:-localhost}
export USERNAME=${USERNAME:-${GVMD_USER:-admin}}
export PASSWORD=${PASSWORD:-${GVMD_PASSWORD:-adminpassword}}
export PASSWORD_FILE=${PASSWORD_FILE:-${GVMD_PASSWORD_FILE:-none}}
export TIMEOUT=${TIMEOUT:-15}
export RELAYHOST=${RELAYHOST:-smtp}
export SMTPPORT=${SMTPPORT:-25}
export AUTO_SYNC=${AUTO_SYNC:-YES}
export AUTO_SYNC_ON_START=${AUTO_SYNC_ON_START:-YES}
export HTTPS=${HTTPS:-true}
export CERTIFICATE=${CERTIFICATE:-none}
export CERTIFICATE_KEY=${CERTIFICATE_KEY:-none}
export TZ=${TZ:-Etc/UTC}
export DEBUG=${DEBUG:-N}
export SSHD=${SSHD:-false}
export DB_PASSWORD=${DB_PASSWORD:-none}
export DB_PASSWORD_FILE=${DB_PASSWORD_FILE:-none}

if [ "$1" == "/usr/bin/supervisord" ]; then

    cp /opt/setup/config/supervisord.conf /etc/supervisord.conf
    cp /opt/setup/config/logrotate-gvm.conf /etc/logrotate.d/gvm
    mkdir -p /etc/redis/
    cp /opt/setup/config/redis-openvas.conf /etc/redis/redis-openvas.conf
    cp /opt/setup/config/sshd_config /etc/ssh/sshd_config

    echo "Starting Postfix for report delivery by email"
    #sed -i "s/^relayhost.*$/relayhost = ${RELAYHOST}:${SMTPPORT}/" /etc/postfix/main.cf
    postconf -e "relayhost = ${RELAYHOST}:${SMTPPORT}"
    #  exec /start.sh
    echo "GVM Started but with > supervisor <"
    if [ ! -f "/firstrun" ]; then
        echo "Running first start configuration..."

        ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone

        touch /firstrun
    fi
fi

exec "$@"
