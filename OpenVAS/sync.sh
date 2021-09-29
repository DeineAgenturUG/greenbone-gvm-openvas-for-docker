#!/bin/bash

sync () {
	echo "--- Sync: Start ---"

	rm /tmp/nvt-feed.tar.xz
	rm -r /tmp/nvt-feed

	echo "Downloading data TAR..."
	curl -o /tmp/nvt-feed.tar.xz https://vulndata.securecompliance.solutions/file/VulnData/nvt-feed.tar.xz # This file is updated at 0:00 UTC every day
	mkdir /tmp/nvt-feed
	
	echo "Extracting data TAR..."
	tar --extract --file=/tmp/nvt-feed.tar.xz --directory=/tmp/nvt-feed
	
	echo "Fixing Permissions..."
	chmod 644 -R /tmp/nvt-feed
	
	echo "Moving Data..."
	rsync -r /tmp/nvt-feed/ /gvm/var/lib/openvas/plugins
	
	rm /tmp/nvt-feed.tar.xz
	rm -r /tmp/nvt-feed
	
	echo "--- Sync: Done ---"
}

sync

while true; do
	sleep 12h
	sync
done
