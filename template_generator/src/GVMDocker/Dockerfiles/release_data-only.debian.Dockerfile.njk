# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

FROM deineagenturug/gvm:latest AS data-only
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=1 \
    OPT_PDF=0

RUN --mount=type=bind,source=./GVMDocker/,target=/opt/context/,rw \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" >/etc/timezone \
    && /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf \
    tar -czf /data.tar.gz /opt/database /var/lib/openvas/plugins /var/lib/gvm

ENV SETUP=0



FROM scratch
COPY --from=data-only --chown=gvm:gvm /data.tar.gz /data.tar.gz
