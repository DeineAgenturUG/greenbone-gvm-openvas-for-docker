#!/usr/bin/env bash

PID_FILE="/run/rsyslogd.pid"

# PreClean up the pid file
if [ -f "${PID_FILE}" ]; then
  rm -f "${PID_FILE}"
fi

# SIGTERM-handler
term_handler() {
  if [ -f "${PID_FILE}" ]; then
    kill -9 "$(cat "${PID_FILE}")"
    rm -f "${PID_FILE}"
  fi
  exit 143 # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'term_handler' SIGTERM SIGINT

#if [ "${SYSTEM_DIST}" == "alpine" ]; then
    #exec /usr/sbin/crond -f -l 8 -c /etc/crontabs
#el
if [ "${SYSTEM_DIST}" == "debian" ]; then
    exec /usr/sbin/rsyslogd -dn
fi
