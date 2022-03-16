#!/bin/bash
set -e

/sync.sh &

/gvm/ospd/bin/ospd-openvas --foreground --socket-mode=0o777

echo "--- OpenVAS OSPD Started ---"

tail -f /gvm/var/log/gvm/openvas.log
