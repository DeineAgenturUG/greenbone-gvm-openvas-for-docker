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
    if [ -d "/opt/file_context/openvas_plugins/" ] && [ ! "$(find /opt/file_context/openvas_plugins/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/openvas_plugins/ /var/lib/openvas/plugins/
    fi
    if [ -d "/opt/file_context/data-objects_gvmd/" ] && [ ! "$(find /opt/file_context/data-objects_gvmd/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/data-objects_gvmd/ /var/lib/gvm/data-objects/gvmd/
    fi
    if [ -d "/opt/file_context/scap-data/" ] && [ ! "$(find /opt/file_context/scap-data/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/scap-data/ /var/lib/gvm/scap-data/
    fi
    if [ -d "/opt/file_context/cert-data/" ] && [ ! "$(find /opt/file_context/cert-data/ -maxdepth 0 -empty)" ]; then
      rsync -a --delete --include=* --include=.* /opt/file_context/cert-data/ /var/lib/gvm/cert-data/
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

echo "x${SETUP}"
if [ "x${SETUP}" == "x1" ]; then
  rsync -a --delete --include=* --include=.* /var/lib/openvas/plugins/ /opt/file_context/openvas_plugins/
  rsync -a --delete --include=* --include=.* /var/lib/gvm/data-objects/gvmd/ /opt/file_context/data-objects_gvmd/
  rsync -a --delete --include=* --include=.* /var/lib/gvm/scap-data/ /opt/file_context/scap-data/
  rsync -a --delete --include=* --include=.* /var/lib/gvm/cert-data/ /opt/file_context/cert-data/
fi

true
