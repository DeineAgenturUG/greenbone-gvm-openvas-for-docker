#!/usr/bin/env bash
set -Eeuo pipefail

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
export AUTO_SYNC=${AUTO_SYNC:-YES}
export AUTO_SYNC_ON_START=${AUTO_SYNC_ON_START:-YES}
export CERTIFICATE=${CERTIFICATE:-none}
export CERTIFICATE_KEY=${CERTIFICATE_KEY:-none}
export TZ=${TZ:-Etc/UTC}
export DEBUG=${DEBUG:-N}
export SSHD=${SSHD:-YES}
export DB_PASSWORD=${DB_PASSWORD:-none}
export DB_PASSWORD_FILE=${DB_PASSWORD_FILE:-none}

# nullmailer
export RELAYHOST=${RELAYHOST:-localhost}
export SMTPPORT=${SMTPPORT:-25}
export MAIL_RELAY_HOST="${MAIL_RELAY_HOST:-${RELAYHOST:-localhost}}"
export MAIL_RELAY_PORT="${MAIL_RELAY_PORT:-${SMTPPORT:-25}}"
export MAIL_RELAY_OPTIONS="${MAIL_RELAY_OPTIONS:-}"
export MAIL_HELOHOST_FQDN="${MAIL_HELOHOST_FQDN:-$(hostname --fqdn)}"
export MAIL_DEFAULT_DOMAIN="${MAIL_DEFAULT_DOMAIN:-$(hostname --fqdn)}"
export MAIL_ADMIN_ADDRESS="${MAIL_ADMIN_ADDRESS:-root@${MAIL_RELAY_HOST}}"


# GSAD Settings:
export HTTPS=${HTTPS:-YES}
GSAD_HSTS_ENABLE="${GSAD_HSTS_ENABLE:-YES}"
GSAD_HSTS_MAX_AGE="${GSAD_HSTS_MAX_AGE:-31536000}"
GSAD_FRAME_OPTS="${GSAD_FRAME_OPTS:-SAMEORIGIN}"
GSAD_CSP="${GSAD_CSP:-"default-src 'self' 'unsafe-inline'; img-src 'self' blob:; frame-ancestors 'self'"}"
GSAD_PER_IP_CONN_LIMIT="${GSAD_PER_IP_CONN_LIMIT:-10}"
GSAD_CORS="${GSAD_CORS:-}"
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