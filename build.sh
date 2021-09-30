#!/bin/bash

docker build -t securecompliance/gvm-libs ./GVM-Libs
docker build -t securecompliance/openvas-smb ./OpenVAS-SMB
docker build -t securecompliance/openvas ./OpenVAS
docker build -t securecompliance/gvmd ./GVMD
docker build -t securecompliance/gsa ./GSA
docker build -t securecompliance/gvm-data-sync ./GVM-Data-Sync
docker build -t securecompliance/gvm-sshd ./SSHD
docker build -t securecompliance/gvm-redis ./Redis
docker build -t securecompliance/gvm-postgres ./PostgreSQL
