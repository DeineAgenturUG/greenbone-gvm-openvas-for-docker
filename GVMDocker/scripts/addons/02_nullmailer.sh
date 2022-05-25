#!/usr/bin/env bash
set -Eeuo pipefail

echo "$(hostname)" >/etc/mailname
echo "${MAIL_DEFAULT_DOMAIN:-localhost}" >/etc/nullmailer/defaultdomain
if [ -n "${MAIL_RELAY_HOST}" ] && [ -n "${MAIL_RELAY_PORT}" ]; then
    echo "${MAIL_RELAY_HOST:-localhost} smtp --port=${MAIL_RELAY_PORT:-25} ${MAIL_RELAY_OPTIONS}" >/etc/nullmailer/remotes
else 
    echo "localhost discard" >/etc/nullmailer/remotes
fi
if [ -n "${MAIL_ADMIN_ADDRESS}" ]; then
    echo "${MAIL_ADMIN_ADDRESS}" >/etc/nullmailer/adminaddr
else
    echo -n >/etc/nullmailer/adminaddr
fi
if [ -n "${MAIL_HELOHOST_FQDN}" ]; then
    echo "${MAIL_HELOHOST_FQDN}" >/etc/nullmailer/helohost
else
    echo -n >/etc/nullmailer/helohost
fi
