#!/usr/bin/env bash
GH_TOKEN=$(cat ~/.github_token)
for name in gvmd gsa gvm-libs gvm-tools ospd ospd-openvas openvas-scanner openvas-smb python-gvm; do
    echo "${name}"
    #jsonData=$(curl --silent \
    #    -H "Authorization: token ${GH_TOKEN}" \
    #    -H "Accept: application/vnd.github.v3+json" \
    #    https://api.github.com/repos/greenbone/${name}/releases)
    #echo "${jsonData}" >"jq_${name}.json"
    #jsonData=$(cat "jq_${name}.json")
    #version=$(echo "${jsonData}" | jq -r .[].tag_name | grep '21\.[0-9]*\.[0-9]*$' -m1)
    version=$(jq -r .[].tag_name <"jq_${name}.json" | grep '21\.[0-9]*\.[0-9]*$' -m1)

    echo "${name}: ${version}"
    #echo "${jsonData}" | jq -r '.[] | select(.tag_name | startswith("${version}")).tarball_url' | xargs echo
    jq --arg PVERSION "${version}" -r '.[] | select(.tag_name | startswith($PVERSION)).tarball_url' <"jq_${name}.json" | xargs curl -L -o "./${name}_${version}.tar.gz"
done
