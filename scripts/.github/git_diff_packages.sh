#!/usr/bin/env bash

for name in gvmd greenbone-security-assistant gvm-libs gvm-tools ospd ospd-openvas openvas openvas-smb py3-gvm; do

    #git diff -- "aports2/community/${name}" "aports/community/${name}"
    #diff -ruN "aports2/community/${name}" "aports/community/${name}" >./patches/"${name}".patch
    cp -a "aports/community/${name}" "aports2/community/"
done
