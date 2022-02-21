#!/bin/bash
#
# Run the first time to setup keys
#
set -euo pipefail

echo 'I AM IN build.sh !!!'
echo 'I AM:'
whoami
cat /etc/apk/keys/build.rsa.pub
cat /home/packager/.abuild/abuild.conf

echo 'Running env'
env

mkdir -p /target/community/noarch/
mkdir -p /target/community/x86_64/

BUILD_CHECKSUM=${CHECKSUM:-0}

BuilldAndSingMe() {
    if [ "${BUILD_CHECKSUM}" == "1" ]; then
        echo '----------------------- Before abuild checksum'
        abuild checksum
    fi
    sleep 1
    echo '----------------------- Before abuild'
    abuild -c -r -P /target
    sleep 1
    # ignore all python packages
    if [ "$1" == "nmap" ] || [ "$1" == "gvm-tools" ] || [ "$1" == "ospd" ] || [ "$1" == "ospd-openvas" ] || [ "$1" == "python-gvm" ]; then
        echo '---------------- I am in IF statement'
        cd /target/community/noarch/ || exit
        cp ../x86_64/nmap-scripts*.apk ./ || true
        cp ../x86_64/nmap-nselibs*.apk ./ || true
        cp ../x86_64/py3-gvm*.apk ./ || true
        cp ../x86_64/gvm-tools*.apk ./ || true
        cp ../x86_64/ospd*.apk ./ || true
        sleep 1
        echo '---------------------- Before apk index'
        apk index -o APKINDEX.tar.gz *.apk
        echo '---------------------- Before abuild-sign'
        env
        abuild-sign APKINDEX.tar.gz
    else
        cd /target/community/x86_64/ || exit
    fi

    sleep 1
    echo 'Before apk index'
    apk index -o APKINDEX.tar.gz *.apk
    echo 'Before signing...'
    abuild-sign APKINDEX.tar.gz
    echo 'After signing...'
}
BuildThis() {
    cd /work/community/"$1"/ || exit
    BuilldAndSingMe "$1"
}
echo 'Before nmap'
BuildThis nmap
echo 'After nmap'
BuildThis gvm-libs
BuildThis openvas-smb
BuildThis gvmd
BuildThis openvas
BuildThis py3-gvm
BuildThis gvm-tools
BuildThis ospd
BuildThis ospd-openvas
BuildThis greenbone-security-assistant
# BuildThis texlive

sleep 10

cd /target/community/x86_64/ || exit
sleep 1
apk index -o APKINDEX.tar.gz *.apk
abuild-sign APKINDEX.tar.gz

cd /target/community/noarch/ || exit
cp ../x86_64/nmap-scripts*.apk ./
cp ../x86_64/nmap-nselibs*.apk ./
cp ../x86_64/py3-gvm*.apk ./
cp ../x86_64/gvm-tools*.apk ./
cp ../x86_64/ospd*.apk ./
sleep 1
apk index -o APKINDEX.tar.gz *.apk
abuild-sign APKINDEX.tar.gz
