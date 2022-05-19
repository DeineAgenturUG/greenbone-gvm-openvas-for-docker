#!/usr/bin/env bash
set -Eeuo pipefail

sudo -u postgres psql -d gvmd -c "UPDATE public.scanners SET host='/run/ospd/ospd-openvas.sock' WHERE name='OpenVAS Default' and (host='/var/run/ospd/ospd.sock' or host='/run/ospd/ospd.sock');"

