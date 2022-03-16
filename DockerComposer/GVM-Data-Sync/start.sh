#!/bin/bash

sync () {
	echo "--- Sync: Start ---"

	rm /tmp/data.tar.xz
	rm -r /tmp/data

	echo "Downloading data TAR..."
	curl -o /tmp/data.tar.xz https://vulndata.securecompliance.solutions/file/VulnData/data.tar.xz # This file is updated at 0:00 UTC every day
	mkdir /tmp/data
	
	echo "Extracting data TAR..."
	tar --extract --file=/tmp/data.tar.xz --directory=/tmp/data
	
	echo "Removing Old Data..."
	rm -rf /gvm/var/lib/gvm/data-objects/gvmd
	rm -rf /gvm/var/lib/gvm/scap-data
	rm -rf /gvm/var/lib/gvm/cert-data
	
	echo "Moving Data..."
	mkdir -p /gvm/var/lib/gvm/data-objects
	mv --force /tmp/data/gvmd-data /gvm/var/lib/gvm/data-objects/gvmd
	mv --force /tmp/data/scap-data /gvm/var/lib/gvm/scap-data
	mv --force /tmp/data/cert-data /gvm/var/lib/gvm/cert-data
	
	echo "Fixing Permissions..."
	chmod 777 -R /gvm/var/lib/gvm/data-objects
	chmod 777 -R /gvm/var/lib/gvm/scap-data
	chmod 777 -R /gvm/var/lib/gvm/cert-data
	
	rm /tmp/data.tar.xz
	rm -r /tmp/data
	
	echo "--- Sync: Done ---"
}

sync

while true; do
	sleep 12h
	sync
done
