#!/usr/bin/env bash
set -Eeo pipefail

mkdir -p /var/lib/gvm/data-objects/gvmd
mkdir -p /var/lib/openvas/plugins
mkdir -p /var/log/gvm

if [ ! -f "/var/lib/gvm/.firstsync" ] && [ -f "/opt/context/gvm-sync-data/gvm-sync-data.tar.xz" ]; then
  mkdir /tmp/data

  echo "Extracting internal data TAR..."
  tar --extract --file=/opt/context/gvm-sync-data/gvm-sync-data.tar.xz --directory=/tmp/data

  chown gvm:gvm -R /tmp/data

  #	ls -lahR /tmp/data

  cp -a /tmp/data/nvt-feed/* /var/lib/openvas/plugins/
  cp -a /tmp/data/gvmd-data/* /var/lib/gvm/data-objects/gvmd
  cp -a /tmp/data/scap-data/* /var/lib/gvm/scap-data/
  cp -a /tmp/data/cert-data/* /var/lib/gvm/cert-data/

  if [ "x${SETUP}" == "x1" ]; then

    if [ -d "/opt/file_context/openvas/" ] && [ ! "$(find /opt/file_context/openvas/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/openvas/ /var/lib/openvas/
    fi
    if [ -d "/opt/file_context/gvm/" ] && [ ! "$(find /opt/file_context/gvm/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/gvm/ /var/lib/gvm/
    fi
  fi

  chown gvm:gvm -R /var/lib/gvm
  chown gvm:gvm -R /var/lib/openvas
  chown gvm:gvm -R /var/log/gvm

  find /var/lib/openvas/ -type d -exec chmod 755 {} +
  find /var/lib/gvm/ -type d -exec chmod 755 {} +
  find /var/lib/openvas/ -type f -exec chmod 644 {} +
  find /var/lib/gvm/ -type f -exec chmod 644 {} +
  find /var/lib/gvm/gvmd/report_formats -type f -name "generate" -exec chmod +x {} \;

  rm -r /tmp/data
fi

# Sync NVTs, CERT data, and SCAP data on container start
/opt/setup/scripts/sync-all.sh
touch /var/lib/gvm/.firstsync

true
