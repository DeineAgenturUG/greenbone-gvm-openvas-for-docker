# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

FROM --platform=linux/amd64 busybox AS data-only
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
COPY --from=${CACHE_IMAGE}:data-only /data.tar.gz /
RUN mkdir -p /output
RUN tar -xf /data.tar.gz -C /output/

FROM ${CACHE_IMAGE}:latest-data AS latest-data
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
ARG SETUP=1
ARG OPT_PDF=0
COPY --from=data-only /output/ /
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime  \
    && echo "$TZ" >/etc/timezone \
    && /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf  \
    && rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

ENV SETUP=0

FROM latest-data
VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
