# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

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

FROM ${CACHE_BUILD_IMAGE}:build_gvm_libs AS build_gvm_libs

FROM ${CACHE_BUILD_IMAGE}:build_base AS build
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
    INSTALL_DIR=${INSTALL_DIR}

ARG OPENVAS_SCANNER_VERSION
ARG OPENVAS_SMB_VERSION
ENV OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION}
ENV OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION}
COPY --from=build_gvm_libs / /

RUN set -eu; \
    echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries; \
	mkdir -p /usr/local/share/keyrings/; \
	cp /opt/context-full/GVMDocker/build/postgres_ACCC4CF8.asc /usr/local/share/keyrings/postgres.gpg.asc; \
	cp /opt/context-full/helper/config/apt-sources.list /etc/apt/sources.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https

RUN curl -sSL https://github.com/greenbone/openvas-smb/archive/refs/tags/v${OPENVAS_SMB_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/openvas-smb/releases/download/v${OPENVAS_SMB_VERSION}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz
RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz \
    && mkdir -p ${BUILD_DIR}/openvas-smb && cd ${BUILD_DIR}/openvas-smb \
    && cmake ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION} \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make DESTDIR=/ install \
    && make DESTDIR=${INSTALL_DIR} install

RUN { \
      echo "/usr/local/lib"; \
      echo "/usr/lib"; \
      echo "${INSTALL_DIR}/usr/lib/"; \
    } >/etc/ld.so.conf.d/openvas.conf && ldconfig
RUN curl -sSL https://github.com/greenbone/openvas-scanner/archive/refs/tags/v${OPENVAS_SCANNER_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/openvas-scanner/releases/download/v${OPENVAS_SCANNER_VERSION}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz \
    && mkdir -p ${BUILD_DIR}/openvas-scanner && cd ${BUILD_DIR}/openvas-scanner \
    && ldconfig \
    && cmake --debug-output ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
    -DOPENVAS_RUN_DIR=/run/ospd \
    && make -j$(nproc) \
    && make DESTDIR=/ install \
    && make DESTDIR=${INSTALL_DIR} install \
    && ldd "${INSTALL_DIR}/usr/sbin/openvas" \
    && ldd "${INSTALL_DIR}/usr/lib/libopenvas_misc.so"


FROM scratch
ARG INSTALL_DIR
COPY --from=build ${INSTALL_DIR}/ /
