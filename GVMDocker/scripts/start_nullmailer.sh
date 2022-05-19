#!/usr/bin/env bash

DAEMON=/usr/sbin/nullmailer-send
NAME=nullmailer
PIDFILE=/var/run/$NAME.pid
NULLTRIGGER=/var/spool/nullmailer/trigger

if [[ -f /lib/lsb/init-functions ]]; then
  . /lib/lsb/init-functions
elif [[ -f /etc/init.d/functions ]]; then
  . /etc/init.d/functions
else
  echo "Linux LSB init function script or Redhat /etc/init.d/functions is required for this script."
  echo "See http://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/iniscrptfunc.html"
  exit 1
fi


if ! pidofproc -p $PIDFILE $DAEMON; then
    if [ ! -p "${NULLTRIGGER}" ]; then
        rm -f "${NULLTRIGGER}"
        mkfifo "${NULLTRIGGER}"
    fi
    chown mail:root "${NULLTRIGGER}"
    chmod 0622 "${NULLTRIGGER}"
    exec $DAEMON & echo $! >${PIDFILE}
fi
