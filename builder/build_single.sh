#!/bin/bash
#
# Run the first time to setup keys
#

PKG=${1:-gvmd}

set -euo pipefail

mkdir -p /target/community/noarch/
mkdir -p /target/community/x86_64/

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

case "${PKG}" in
libs | "gvm-libs") BuildThis gvm-libs ;;
"openvas-smb") BuildThis openvas-smb ;;
"gvmd") BuildThis gvmd ;;
"openvas") BuildThis openvas ;;
"py3-gvm") BuildThis py3-gvm ;;
tools | "gvm-tools") BuildThis gvm-tools ;;
"ospd") BuildThis ospd ;;
"ospd-openvas") BuildThis ospd-openvas ;;
"greenbone-security-assistant") BuildThis greenbone-security-assistant ;;
#"texlive") BuildThis texlive ;;
*) echo "  ERROR" ;;
esac

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
