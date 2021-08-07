#!/bin/bash
#
# Run the first time to setup keys
#
set -euo pipefail

BuildThis() {
    cd /work/community/"$1"/ || exit
    abuild checksum
}

BuildThis gvm-libs
BuildThis openvas-smb
BuildThis gvmd
BuildThis openvas
BuildThis py3-gvm
BuildThis gvm-tools
BuildThis ospd-openvas
BuildThis greenbone-security-assistant
# BuildThis texlive
