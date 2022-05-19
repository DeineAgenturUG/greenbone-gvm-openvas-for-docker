#!/usr/bin/env bash
set -Eeuo pipefail

export RELAYHOST=${RELAYHOST}
export SMTPPORT=${SMTPPORT:-25}
export MAIL_RELAY_HOST="${MAIL_RELAY_HOST:-${RELAYHOST}}"
export MAIL_RELAY_PORT="${MAIL_RELAY_PORT:-${SMTPPORT:-25}}"
export MAIL_RELAY_OPTIONS="${MAIL_RELAY_OPTIONS}"
export MAIL_DEFAULT_DOMAIN="${MAIL_DEFAULT_DOMAIN:-$(hostname --fqdn)}"
export MAIL_ADMIN_ADDRESS="${MAIL_ADMIN_ADDRESS}"

if [ -n "$MAIL_RELAY_HOST" ] && [ -n "$MAIL_RELAY_PORT" ] && [ -n "$MAIL_ADMIN_ADDRESS" ]; then

    if [ ! -e /etc/nullmailer/remotes ] && [ ! -e /etc/nullmailer/defaultdomain ] && [ ! -e /etc/mailname ]; then
        debconf-set-selections <<EOF
nullmailer shared/mailname string $(hostname --fqdn)
nullmailer nullmailer/defaultdomain string ${MAIL_DEFAULT_DOMAIN:-localhost}
nullmailer nullmailer/relayhost string ${MAIL_RELAY_HOST:-localhost} smtp --port=${MAIL_RELAY_PORT:-25} ${MAIL_RELAY_OPTIONS}
nullmailer nullmailer/adminaddr string ${MAIL_ADMIN_ADDRESS}
EOF
        apt-get update
        apt-get install -y --no-install-recommends nullmailer mailutils
        rm -rf /var/lib/apt/lists/*
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    fi

fi
