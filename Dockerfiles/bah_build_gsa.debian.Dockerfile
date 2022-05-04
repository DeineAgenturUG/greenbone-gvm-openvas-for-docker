# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagentur2/gvm
ARG CACHE_BUILD_IMAGE=deineagentur2/gvm-build

ARG POSTGRESQL_VERSION="13"
ARG GSAD_VERSION="21.4.4"
ARG GSA_VERSION="21.4.4"
ARG GVM_LIBS_VERSION="21.4.4"
ARG GVMD_VERSION="21.4.5"
ARG OPENVAS_SCANNER_VERSION="21.4.4"
ARG OPENVAS_SMB_VERSION="21.4.0"
ARG PYTHON_GVM_VERSION="21.11.0"
ARG OSPD_OPENVAS_VERSION="21.4.4"
ARG GVM_TOOLS_VERSION="21.10.0"

ARG SUPVISD=supervisorctl
ARG GVMD_USER
ARG GVMD_PASSWORD
ARG USERNAME=admin
ARG PASSWORD=adminpassword
ARG PASSWORD_FILE=none
ARG TIMEOUT=15
ARG DEBUG=N
ARG RELAYHOST=smtp
ARG SMTPPORT=25
ARG AUTO_SYNC=YES
ARG AUTO_SYNC_ON_START=YES
ARG CERTIFICATE=none
ARG CERTIFICATE_KEY=none
ARG HTTPS=true
ARG TZ=Etc/UTC
ARG SSHD=false
ARG DB_PASSWORD=none

ARG INSTALL_PREFIX=/usr
ARG SOURCE_DIR=/source
ARG BUILD_DIR=/build
ARG INSTALL_DIR=/install
ARG DESTDIR=/install

FROM --platform=$BUILDPLATFORM node:14-alpine AS build
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
ARG INSTALL_PREFIX
ARG SOURCE_DIR
ARG BUILD_DIR
ARG INSTALL_DIR
ARG DESTDIR
ENV INSTALL_PREFIX=${INSTALL_PREFIX} \
    SOURCE_DIR=${SOURCE_DIR} \
    BUILD_DIR=${BUILD_DIR} \
    INSTALL_DIR=${INSTALL_DIR} \
    DESTDIR=${DESTDIR}

ARG GSA_VERSION
ENV GSA_VERSION=${GSA_VERSION}

RUN apk add --no-cache wget curl gnupg tar \
    && mkdir -p ${SOURCE_DIR} \
    && mkdir -p ${BUILD_DIR} \
    && mkdir -p ${INSTALL_DIR} \
    && curl -O https://www.greenbone.net/GBCommunitySigningKey.asc \
    && gpg --import <GBCommunitySigningKey.asc \
    && ( \
        echo 5 \
        && echo y \
        && echo save \
    ) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <GBCommunitySigningKey.asc | awk '$1=="keyid:"{print$2;exit}')" trust

RUN curl -sSL https://github.com/greenbone/gsa/archive/refs/tags/v${GSA_VERSION}.tar.gz -o ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/gsa/releases/download/v${GSA_VERSION}/gsa-${GSA_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz.asc \
    && ls -lahr ${SOURCE_DIR} \
    && gpg --verify ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz.asc ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gsa-${GSA_VERSION}.tar.gz \
    && ls -lahr ${SOURCE_DIR} \
    && mkdir -p ${SOURCE_DIR}/gsa-${GSA_VERSION} \
    && cd ${SOURCE_DIR}/gsa-${GSA_VERSION} \
    && npm i -g yarn \
    && yarn \
    && yarn build \
    && mkdir -p ${INSTALL_DIR}${INSTALL_PREFIX}/share/gvm/gsad/web/ \
    && cp -r build/* ${INSTALL_DIR}${INSTALL_PREFIX}/share/gvm/gsad/web/
