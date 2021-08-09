#!/usr/bin/env bash
set -Eeuo pipefail

MASTER_PORT=${MASTER_PORT:-22}

if [ -z "${MASTER_ADDRESS}" ]; then
	echo "ERROR: The environment variable \"MASTER_ADDRESS\" is not set"
	exit 1
fi

if [ ! -d /var/lib/gvm/.ssh ]; then
	mkdir -p /var/lib/gvm/.ssh
fi

if [ ! -f /var/lib/gvm/.ssh/known_hosts ]; then
	echo "Getting Master SSH key..."
	ssh-keyscan -t ed25519 -p "${MASTER_PORT}" "${MASTER_ADDRESS}" >/var/lib/gvm/.ssh/known_hosts.temp
	mv /var/lib/gvm/.ssh/known_hosts.temp /var/lib/gvm/.ssh/known_hosts
fi

if [ ! -f /var/lib/gvm/.ssh/key ]; then
	echo "Setup SSH key..."
	ssh-keygen -t ed25519 -f /var/lib/gvm/.ssh/key -N "" -C "$(cat /var/lib/gvm/.scannerid)"
fi

## Start Redis

if [ ! -d "/run/redis" ]; then
	mkdir -p /run/redis
fi

if [ -S /run/redis/redis.sock ]; then
	rm /run/redis/redis.sock
fi

if [ ! -d "/run/redis-openvas" ]; then
	echo "create /run/redis-openvas"
	mkdir -p /run/redis-openvas
fi

if [ -S /run/redis-openvas/redis.sock ]; then
	rm /run/redis-openvas/redis.sock
fi

${SUPVISD} start redis
${SUPVISD} status redis

echo "Wait for redis socket to be created..."
while [ ! -S /run/redis-openvas/redis.sock ]; do
	sleep 1
done

echo "Testing redis status..."
X="$(redis-cli -s /run/redis-openvas/redis.sock ping)"
while [ "${X}" != "PONG" ]; do
	echo "Redis not yet ready..."
	sleep 1
	X="$(redis-cli -s /run/redis-openvas/redis.sock ping)"
done
echo "Redis ready."

echo "+++++++++++++++++++++++++++++++++++"
echo "+ Enabling Automating NVT updates +"
echo "+++++++++++++++++++++++++++++++++++"
${SUPVISD} start GVMUpdate
if [ "${DEBUG}" == "Y" ]; then
	${SUPVISD} status GVMUpdate
fi
sleep 5

#############################
# Remove leftover pid files #
#############################

if [ -f /var/run/ospd.pid ]; then
	rm /var/run/ospd.pid
fi

if [ -S /tmp/ospd.sock ]; then
	rm /tmp/ospd.sock
fi

if [ -S /var/run/ospd/ospd.sock ]; then
	rm /var/run/ospd/ospd.sock
fi

if [ ! -d /var/run/ospd ]; then
	mkdir -p /var/run/ospd
fi

echo "Starting Open Scanner Protocol daemon for OpenVAS..."
${SUPVISD} start ospd-openvas
if [ "${DEBUG}" == "Y" ]; then
	${SUPVISD} status ospd-openvas
fi

while [ ! -S /var/run/ospd/ospd.sock ]; do
	sleep 1
done

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Your OpenVAS Scanner container is now ready to use! +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "-------------------------------------------------------"
echo "Scanner id: $(cat /var/lib/gvm/.scannerid)"
echo "Public key: $(cat /var/lib/gvm/.ssh/key.pub)"
echo "Master host key (Check that it matches the public key from the master):"
cat /var/lib/gvm/.ssh/known_hosts
echo "-------------------------------------------------------"
echo "If you start the firsttime, you should now add the scanner"
echo "to the gvmd container, via the /add/scanner.sh"
echo "After it, you need to restart this container!"
echo "-------------------------------------------------------"
touch /var/lib/gvm/.firststart
if [ -f /var/lib/gvm/.secondstart ]; then
	${SUPVISD} start autossh
	if [ "${DEBUG}" == "Y" ]; then
		${SUPVISD} status autossh
	fi
fi

echo "++++++++++++++++"
echo "+ Tailing logs +"
echo "++++++++++++++++"
tail -F /var/log/gvm/*
