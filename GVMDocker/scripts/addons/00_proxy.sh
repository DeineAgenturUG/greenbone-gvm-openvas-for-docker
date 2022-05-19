#!/usr/bin/env bash
set -Eeuo pipefail

export HTTP_PROXY="${HTTP_PROXY:-${http_proxy:-}}"
export HTTPS_PROXY="${HTTPS_PROXY:-${https_proxy:-}}"
export RSYNC_PROXY="${RSYNC_PROXY:-${rsync_proxy:-}}"
export FTP_PROXY="${FTP_PROXY:-${ftp_proxy:-}}"
export NO_PROXY="${NO_PROXY:-${no_proxy:-}}"
if [[ -n "${HTTP_PROXY}" ]]; then
    touch /etc/apt/apt.conf.d/99proxy
    {
        echo "Acquire::http::Proxy \"${HTTP_PROXY}\";"
    } >/etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${HTTPS_PROXY}" ]]; then
    touch /etc/apt/apt.conf.d/99proxy
    {
        echo "Acquire::https::Proxy \"${HTTP_PROXY}\";"
    } >>/etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${FTP_PROXY}" ]]; then
    touch /etc/apt/apt.conf.d/99proxy
    {
        echo "Acquire::ftp::Proxy \"${FTP_PROXY}\";"
    } >>/etc/apt/apt.conf.d/99proxy
fi
if [[ -n "${NO_PROXY}" ]]; then
    touch /etc/apt/apt.conf.d/99proxy
    OLDIFS=$IFS
    IFS=',' read -ra NO_PROXY_HOST_ARRAY <<<"${NO_PROXY}"
    if [[ "${#NO_PROXY_HOST_ARRAY[@]}" == 0 ]]; then
        IFS=' ' read -ra NO_PROXY_HOST_ARRAY <<<"${NO_PROXY}"
    fi
    for NO_PROXY_HOST in "${NO_PROXY_HOST_ARRAY[@]}"; do
        if [[ -n "${HTTP_PROXY}" ]]; then
            {
                echo "Acquire::http::proxy::${NO_PROXY_HOST} \"DIRECT\";"
            } >>/etc/apt/apt.conf.d/99proxy
        fi
        if [[ -n "${HTTPS_PROXY}" ]]; then
            {
                echo "Acquire::https::proxy::${NO_PROXY_HOST} \"DIRECT\";"
            } >>/etc/apt/apt.conf.d/99proxy
        fi
        if [[ -n "${FTP_PROXY}" ]]; then
            {
                echo "Acquire::ftp::proxy::${NO_PROXY_HOST} \"DIRECT\";"
            } >>/etc/apt/apt.conf.d/99proxy
        fi
    done
    IFS=$OLDIFS
fi
