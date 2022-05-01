# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

FROM docker.io/deineagenturug/gvm-develop:latest AS latest-data
ARG SETUP_ARCH
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=1 \
    OPT_PDF=0

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" >/etc/timezone\
    && /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf \
    && (rm -rfv /var/lib/gvm/CA || true) \
    && (rm -rfv /var/lib/gvm/private || true) \
    && (rm /etc/localtime || true) \
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"
ENV SETUP=0
