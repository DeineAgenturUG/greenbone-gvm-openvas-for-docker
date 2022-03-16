
FROM --platform=$BUILDPLATFORM node:14-alpine AS build_gsa
ARG GSA_VERSION
ENV GSA_VERSION=${GSA_VERSION} \
    INSTALL_PREFIX=/usr \
    SOURCE_DIR=/source\
    BUILD_DIR=/build \
    INSTALL_DIR=/install \
    DESTDIR=/install

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
    && mkdir -p ${DESTDIR}${INSTALL_PREFIX}/share/gvm/gsad/web/ \
    && cp -r build/* ${DESTDIR}${INSTALL_PREFIX}/share/gvm/gsad/web/
