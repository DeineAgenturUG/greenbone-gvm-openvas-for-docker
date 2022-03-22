# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

FROM ${CACHE_IMAGE}:latest-data AS latest-data-full
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
ARG SETUP=1
ARG OPT_PDF=1
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
        texlive-fonts-recommended \
        texlive-latex-extra ; \
    unset OPT_PDF \
    && rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

ENV SETUP=0

FROM ${CACHE_IMAGE}:latest-data
VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
