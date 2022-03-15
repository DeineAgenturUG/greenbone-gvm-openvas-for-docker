#!/usr/bin/env bash

listeq=": "
if [[ "${CI}" == "true" ]]; then
  listeq="="
fi

for name in gvmd gsa gsad gvm-libs gvm-tools ospd-openvas openvas-scanner openvas-smb python-gvm; do
    package_name="${name^^}"
    echo "${package_name//-/_}_VERSION${listeq}$(gh api "repos/greenbone/${name}/releases" -q '.[].tag_name' | grep -E '^v[0-9]*\.[0-9]*\.[0-9]*$' -m1)"
    sleep $(( $RANDOM % 3 + 1 ))s
done
