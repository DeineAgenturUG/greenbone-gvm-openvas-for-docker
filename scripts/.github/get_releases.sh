#!/usr/bin/env bash

for name in gvmd gsa gsad gvm-libs gvm-tools ospd-openvas openvas-scanner openvas-smb python-gvm; do

    echo "${${name^^}//-/_}: $(curl --silent \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/greenbone/${name}/releases | jq -r .[].tag_name | grep '^v21\.[0-9]*\.[0-9]*$' -m1)"
done
