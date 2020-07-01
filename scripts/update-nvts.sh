#!/usr/bin/env bash
set -Eeuo pipefail

while true; do
	echo "Updating NVTs..."
	su -c "rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/nvt-feed /usr/local/var/lib/openvas/plugins" openvas-sync
	sleep 43200
done
