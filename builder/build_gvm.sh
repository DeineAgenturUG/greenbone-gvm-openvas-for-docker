#!/bin/bash
#
# Run the first time to setup keys
#

BUILD_CHECKSUM=${CHECKSUM:-0}

BuilldAndSingMe() {
    if [ "${BUILD_CHECKSUM}" == "1" ]; then
        abuild checksum
    fi
    sleep 1
    abuild -c -r -P /target
    sleep 1
    cd /target/community/x86_64/ || exit
    sleep 1
    apk index -o APKINDEX.tar.gz *.apk
    abuild-sign APKINDEX.tar.gz
}
BuildThis() {
    cd /work/community/"$1"/ || exit
    BuilldAndSingMe
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

sleep 10

cd /target/community/x86_64/ || exit
sleep 1
apk index -o APKINDEX.tar.gz *.apk
abuild-sign APKINDEX.tar.gz

cd /target/community/noarch/ || exit
cp ../x86_64/py3-gvm*.apk ./
cp ../x86_64/gvm-tools*.apk ./
cp ../x86_64/ospd*.apk ./
sleep 1
apk index -o APKINDEX.tar.gz *.apk
abuild-sign APKINDEX.tar.gz
