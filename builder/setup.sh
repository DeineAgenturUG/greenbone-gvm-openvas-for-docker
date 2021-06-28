#!/bin/bash
#
# Run the first time to setup keys
#

set -e

sudo chown packager:packager ~/.abuild/

pub_files1=(/home/packager/.abuild/*.pub)
numpub1=${#pub_files1[@]}

if [ ! -f ~/.abuild/abuild.conf ] || [ "${numpub1}" == "0" ]; then
    abuild-keygen -a -i
fi

pub_files2=(/home/packager/.abuild/*.pub)
numpub2=${#pub_files2[@]}

if [ "${numpub2}" -gt "0" ]; then

    export $(grep -v '#.*' /home/packager/.abuild/abuild.conf | xargs)

    sudo cp "${PACKAGER_PRIVKEY}.pub" /etc/apk/keys/
    sudo chown -R root: /etc/apk/keys/
    sudo apk update
    unset PACKAGER_PRIVKEY
fi

exec sh
