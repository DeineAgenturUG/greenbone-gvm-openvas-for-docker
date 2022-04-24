#!/usr/bin/env bash
set -Eeuo pipefail
export HTTP_PROXY="${HTTP_PROXY:-${http_proxy:-}}"
export HTTPS_PROXY="${HTTPS_PROXY:-${https_proxy:-}}"
export RSYNC_PROXY="${RSYNC_PROXY:-${rsync_proxy:-}}"
export FTP_PROXY="${FTP_PROXY:-${ftp_proxy:-}}"
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
    echo "Acquire::https::Proxy \"${HTTP_PROXY}\";"
  } >> /etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${FTP_PROXY}" ]]; then
  touch /etc/apt/apt.conf.d/99proxy
  {
    echo "Acquire::ftp::Proxy \"${FTP_PROXY}\";"
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
export HTTPS=${HTTPS:-YES}
export CERTIFICATE=${CERTIFICATE:-none}
export CERTIFICATE_KEY=${CERTIFICATE_KEY:-none}
export TZ=${TZ:-Etc/UTC}
export DEBUG=${DEBUG:-N}
export SSHD=${SSHD:-YES}
export DB_PASSWORD=${DB_PASSWORD:-none}
export DB_PASSWORD_FILE=${DB_PASSWORD_FILE:-none}

# GSAD Settings:
GSAD_HSTS_ENABLE="${GSAD_HSTS_ENABLE:-YES}"
GSAD_HSTS_MAX_AGE="${GSAD_HSTS_MAX_AGE:-31536000}"
GSAD_FRAME_OPTS="${GSAD_FRAME_OPTS:-SAMEORIGIN}"
GSAD_CSP="${GSAD_CSP:-"default-src 'self' 'unsafe-inline'; img-src 'self' blob:; frame-ancestors 'self'"}"
GSAD_PER_IP_CONN_LIMIT="${GSAD_PER_IP_CONN_LIMIT:-10}"
GSAD_CORS="${GSAD_CORS:}"
GSAD_OPTIONS=()

if [[ "${GSAD_HSTS_ENABLE}" =~ ^(yes|y|YES|Y|true|TRUE)$ ]]; then
  GSAD_OPTIONS+=("--http-sts")
  GSAD_OPTIONS+=("--http-sts-max-age=\"${GSAD_HSTS_MAX_AGE}\"")
fi
GSAD_OPTIONS+=("--http-frame-opts=\"${GSAD_FRAME_OPTS}\"")
GSAD_OPTIONS+=("--http-csp=\"${GSAD_CSP}\"")
GSAD_OPTIONS+=("--per-ip-connection-limit=${GSAD_PER_IP_CONN_LIMIT}")
if [[ "x${GSAD_CORS}" != "x" ]]; then
  GSAD_OPTIONS+=("--http-cors=\"${GSAD_CORS}\"")
fi
export GSAD_OPTS="${GSAD_OPTIONS[*]}"

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
