#!/usr/bin/env bash
set -x
GH_TOKEN=$(cat ~/.github_token)
MYDIR=$(
    cd $(dirname $0)
    pwd
)

declare -A TOOLMATCHES
TOOLMATCHES["gsa"]="greenbone-security-assistant"
TOOLMATCHES["gvmd"]="gvmd"
TOOLMATCHES["gvm-libs"]="gvm-libs"
TOOLMATCHES["gvm-tools"]="gvm-tools"
TOOLMATCHES["openvas-scanner"]="openvas"
TOOLMATCHES["openvas-smb"]="openvas-smb"
TOOLMATCHES["ospd"]="ospd"
TOOLMATCHES["ospd-openvas"]="ospd-openvas"
TOOLMATCHES["python-gvm"]="py3-gvm"

for name in gvmd gsa gvm-libs gvm-tools ospd ospd-openvas openvas-scanner openvas-smb python-gvm; do

    # ignore all python packages
    if [ "${name}" == "gvm-tools" ] || [ "${name}" == "ospd" ] || [ "${name}" == "ospd-openvas" ] || [ "${name}" == "python-gvm" ]; then
        continue
    fi

    LOCALDIR="${MYDIR}/aports2/community/${TOOLMATCHES[$name]}/"
    LOCALREPO="${MYDIR}/src/${TOOLMATCHES[$name]}"
    echo "> ${name} (${LOCALDIR}"
    (
        cd "${LOCALREPO}" || exit 1
        #   grep -E -o "([a-z0-9-]*.patch)" aports2/community/gvm-libs/APKBUILD | awk '!seen[$0]++'

        for patch in $(cat "${LOCALDIR}APKBUILD" | grep -E -o "([a-z0-9-]*.patch)" | grep -v "glib_full.patch" | awk '!seen[$0]++'); do
            echo "  > ${patch}"
            git apply "${LOCALDIR}${patch}" || exit 1
            git add .
            git commit -m "Patch: ${patch}"
        done
    )
    (
        cd "${LOCALREPO}" || exit 1
        git grep -rl "#include <glib.h>" . | xargs sed -i 's/#include <glib.h>/#include <glib-2.0\/glib.h>/g'
        git grep -rl "#include <glib/" . | xargs sed -i 's/#include <glib\//#include <glib-2.0\/glib\//g'
        git grep -rl "#include <gio/gio.h>" . | xargs sed -i 's/#include <gio\/gio.h>/#include <glib-2.0\/gio\/gio.h>/g'
    )

    (
        cd "${LOCALREPO}" || exit 1
        #git add .
        #git commit -m "Patch glib2" || exit
        #git format-patch -k -o "${LOCALDIR}" -1
        git diff >"${LOCALDIR}glib_full.patch"
    )

done
