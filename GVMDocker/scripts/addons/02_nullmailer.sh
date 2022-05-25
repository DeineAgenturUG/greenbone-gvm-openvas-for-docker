#!/usr/bin/env bash
set -Eeuo pipefail

if [ -n "${MAIL_RELAY_HOST}" ] && [ -n "${MAIL_RELAY_PORT}" ] && [ -n "${MAIL_ADMIN_ADDRESS}" ]; then
    echo "$(hostname)" >/etc/mailname
    echo "${MAIL_DEFAULT_DOMAIN:-localhost}" >/etc/nullmailer/defaultdomain
    echo "${MAIL_ADMIN_ADDRESS}" >/etc/nullmailer/adminaddr
    echo "${MAIL_RELAY_HOST:-localhost} smtp --port=${MAIL_RELAY_PORT:-25} ${MAIL_RELAY_OPTIONS}" >/etc/nullmailer/remotes
    echo "${MAIL_HELOHOST_FQDN}" >/etc/nullmailer/helohost
fi
