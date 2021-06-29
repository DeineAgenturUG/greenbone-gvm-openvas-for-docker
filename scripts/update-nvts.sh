#!/usr/bin/env bash
# This script update the NVTs in the background every 12 hours.
set -Eeuo pipefail

if [ ! -f "/var/lib/gvm/.firstsync" ]; then
	echo "Downloading data TAR to speed up first sync..."
	mkdir /tmp/data

	echo "Extracting internal data TAR..."
	tar --extract --file=/opt/gvm-sync-data.tar.xz --directory=/tmp/data

	chown gvm:gvm -R /tmp/data

	cp -a /tmp/data/nvt-feed/* /var/lib/openvas/plugins
	chown gvm:gvm -R /var/lib/openvas

	find /var/lib/openvas/ -type d -exec chmod 755 {} +
	find /var/lib/openvas/ -type f -exec chmod 644 {} +

	rm /tmp/data.tar.xz
	rm -r /tmp/data
fi

while true; do
	echo "Running Automatic NVT update..."
	su -c "rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/nvt-feed /var/lib/openvas/plugins" gvm
	sleep 43200
done
