#!/usr/bin/env bash
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
    echo "> ${name}"
    jsonData=$(curl --silent \
        -H "Authorization: token ${GH_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/greenbone/${name}/releases)
    #echo "${jsonData}" >"jq_${name}.json"
    #jsonData=$(cat "jq_${name}.json")
    version=$(echo "${jsonData}" | jq -r .[].tag_name | grep '21\.[0-9]*\.[0-9]*$' -m1)
    #version=$(jq -r .[].tag_name <"jq_${name}.json" | grep '21\.[0-9]*\.[0-9]*$' -m1)

    echo ">>> ${name}: ${version}"
    #rm -rf ./aports2/community/${TOOLMATCHES[$name]}/src/
    LOCALREPO="./aports2/community/${TOOLMATCHES[$name]}/src"
    git clone https://github.com/greenbone/${name}.git "${LOCALREPO}" 2>/dev/null || git -C "${LOCALREPO}" pull
    git -C "${LOCALREPO}" checkout "tags/${version}"
    git -C "${LOCALREPO}" reset --hard HEAD
    #echo "${jsonData}" | jq --arg PVERSION "${version}" -r '.[] | select(.tag_name | startswith($PVERSION)).tarball_url' <"jq_${name}.json" | xargs curl -L -o "./${name}_${version}.tar.gz"
    #jq --arg PVERSION "${version}" -r '.[] | select(.tag_name | startswith($PVERSION)).tarball_url' <"jq_${name}.json" | xargs curl -L -o "./${name}_${version}.tar.gz"
done
