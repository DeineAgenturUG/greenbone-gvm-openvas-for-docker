# syntax=docker/dockerfile:1.4

ARG POSTGRESQL_VERSION="13"
ARG GSAD_VERSION="21.4.4"
ARG GSA_VERSION="21.4.4"
ARG GVM_LIBS_VERSION="21.4.4"
ARG GVMD_VERSION="21.4.5"
ARG OPENVAS_SCANNER_VERSION="21.4.4"
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

FROM debian:11-slim as base
ARG POSTGRESQL_VERSION
ARG GSAD_VERSION
ARG GSA_VERSION
ARG GVM_LIBS_VERSION
ARG GVMD_VERSION
ARG OPENVAS_SCANNER_VERSION
ARG OPENVAS_SMB_VERSION
ARG PYTHON_GVM_VERSION
ARG OSPD_OPENVAS_VERSION
ARG GVM_TOOLS_VERSION

ENV POSTGRESQL_VERSION=${POSTGRESQL_VERSION} \
    GSAD_VERSION=${GSAD_VERSION} \
    GSA_VERSION=${GSA_VERSION} \
    GVM_LIBS_VERSION=${GVM_LIBS_VERSION} \
    GVMD_VERSION=${GVMD_VERSION} \
    OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION} \
    OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION} \
    PYTHON_GVM_VERSION=${PYTHON_GVM_VERSION} \
    OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION} \
    GVM_TOOLS_VERSION=${GVM_TOOLS_VERSION} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    INSTALL_PREFIX=/usr \
    SOURCE_DIR=/source\
    BUILD_DIR=/build \
    INSTALL_DIR=/install \
    DESTDIR=/install
RUN apt-get update \
    && apt-get -yq upgrade \
    && apt-get install --no-install-recommends --assume-yes \
        apt-utils \
        coreutils \
        build-essential \
        cmake \
        git \
        curl \
        gnupg \
        lsb-release \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        sudo \
        wget \
    && echo 'deb http://deb.debian.org/debian bullseye-backports main' | tee /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get -yq upgrade \
    && echo "Acquire::http::Proxy \"${http_proxy}\";" | tee /etc/apt/apt.conf.d/30proxy \
    && echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" | tee /etc/apt/apt.conf.d/10no-recommend-installs \
    && mkdir -p "${SOURCE_DIR}" \
    && mkdir -p "${BUILD_DIR}" \
    && mkdir -p "${INSTALL_DIR}" \
    && python3 -m pip install --upgrade pip \
    && curl -O https://www.greenbone.net/GBCommunitySigningKey.asc \
       && gpg --import <GBCommunitySigningKey.asc \
       && ( \
           echo 5 \
           && echo y \
           && echo save \
       ) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <GBCommunitySigningKey.asc | awk '$1=="keyid:"{print$2;exit}')" trust \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get -yq upgrade \
    && apt-get -yq install \
      postgresql-${POSTGRESQL_VERSION} \
      postgresql-server-dev-${POSTGRESQL_VERSION} \
      postgresql-client-${POSTGRESQL_VERSION} \
      postgresql-common \
      postgresql-client-common


# Install required dependencies for gvm-libs
RUN apt-get install -y --no-install-recommends \
    bison \
    dpkg \
    fakeroot \
    gcc-mingw-w64 \
    gnupg \
    gnutls-bin \
    gpgsm \
    heimdal-dev \
    libgcrypt20-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libgpgme-dev \
    libgssapi3-heimdal \
    libhdb9-heimdal \
    libhiredis-dev \
    libical-dev \
    libksba-dev \
    libldap2-dev \
    libmicrohttpd-dev \
    libnet1 \
    libnet1-dev \
    libpcap-dev \
    libpopt-dev \
    libpq-dev \
    libradcli-dev \
    libsnmp-dev \
    libssh-gcrypt-dev \
    libunistring-dev \
    libxml2-dev \
    nmap \
    nsis \
    openssh-client \
    perl-base \
    python3 \
    python3-cffi \
    python3-defusedxml \
    python3-deprecated \
    python3-impacket \
    python3-lxml \
    python3-packaging \
    python3-paho-mqtt \
    python3-paramiko \
    python3-pip \
    python3-psutil \
    python3-redis \
    python3-setuptools \
    python3-wrapt \
    rpm \
    rsync \
    smbclient \
    snmp \
    socat \
    sshpass \
    uuid-dev  \
    wget \
    xml-twig-tools \
    xmlstarlet \
    xsltproc \
    zip \
    && python3 -m pip install --upgrade setuptools


FROM base AS build_gvm_libs
ARG GVM_LIBS_VERSION
ENV GVM_LIBS_VERSION=${GVM_LIBS_VERSION}

# Download and install gvm-libs
RUN curl -sSL "https://github.com/greenbone/gvm-libs/archive/refs/tags/v${GVM_LIBS_VERSION}.tar.gz" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz" \
    && curl -sSL "https://github.com/greenbone/gvm-libs/releases/download/v${GVM_LIBS_VERSION}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" \
    && gpg --verify "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Unpack the gvm-libs tarball
RUN tar -C "${SOURCE_DIR}" -xvzf "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Build and install gvm-libs
RUN mkdir -p "${BUILD_DIR}/gvm-libs" && cd "${BUILD_DIR}/gvm-libs"
RUN cmake "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}" \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    && make "-j$(nproc)"\
    && make DESTDIR="${INSTALL_DIR}" install


FROM base AS build_gvmd
ARG GVMD_VERSION
ARG POSTGRESQL_VERSION
ENV POSTGRESQL_VERSION=${POSTGRESQL_VERSION} \
    GVMD_VERSION=${GVMD_VERSION}

COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig

# Download and install gvmd
RUN curl -sSL https://github.com/greenbone/gvmd/archive/refs/tags/v${GVMD_VERSION}.tar.gz -o ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/gvmd/releases/download/v${GVMD_VERSION}/gvmd-${GVMD_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz.asc ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gvmd-${GVMD_VERSION}.tar.gz\
    && mkdir -p ${BUILD_DIR}/gvmd && cd ${BUILD_DIR}/gvmd

RUN cmake ${SOURCE_DIR}/gvmd-${GVMD_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DLOCALSTATEDIR=/var \
    -DSYSCONFDIR=/etc \
    -DGVM_DATA_DIR=/var \
    -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \
    -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
    -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
    -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
    -DDEFAULT_CONFIG_DIR=/etc/default \
    -DLOGROTATE_DIR=/etc/logrotate.d \
    && make -j$(nproc) \
    && make DESTDIR=${INSTALL_DIR} install


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

FROM base AS build_gsad
ARG GSAD_VERSION
ENV GSAD_VERSION=${GSAD_VERSION}
COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
RUN curl -sSL https://github.com/greenbone/gsad/archive/refs/tags/v${GSAD_VERSION}.tar.gz -o ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/gsad/releases/download/v${GSAD_VERSION}/gsad-${GSAD_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc \
    &&gpg --verify ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz
RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz \
    && mkdir -p ${BUILD_DIR}/gsad && cd $_ \
    && cmake ${SOURCE_DIR}/gsad-${GSAD_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DLOGROTATE_DIR=/etc/logrotate.d \
    -DGVMD_RUN_DIR=/run/gvmd \
    -DGSAD_RUN_DIR=/run/gsad \
    -DGSAD_PID_DIR=/run/gsad \
    && make -j$(nproc) \
    && make DESTDIR=${INSTALL_DIR} install

FROM base AS build_openvas_smb
ARG OPENVAS_SMB_VERSION
ENV OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION}
COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
RUN curl -sSL https://github.com/greenbone/openvas-smb/archive/refs/tags/v${OPENVAS_SMB_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/openvas-smb/releases/download/v${OPENVAS_SMB_VERSION}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz
RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION}.tar.gz \
    && mkdir -p ${BUILD_DIR}/openvas-smb && cd ${BUILD_DIR}/openvas-smb \
    && cmake ${SOURCE_DIR}/openvas-smb-${OPENVAS_SMB_VERSION} \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make DESTDIR=${INSTALL_DIR} install


FROM base AS build_openvas_scanner
ARG OPENVAS_SCANNER_VERSION
ENV OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION}
COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
RUN curl -sSL https://github.com/greenbone/openvas-scanner/archive/refs/tags/v${OPENVAS_SCANNER_VERSION}.tar.gz -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/openvas-scanner/releases/download/v${OPENVAS_SCANNER_VERSION}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz.asc ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION}.tar.gz \
    && mkdir -p ${BUILD_DIR}/openvas-scanner && cd ${BUILD_DIR}/openvas-scanner \
    && cmake ${SOURCE_DIR}/openvas-scanner-${OPENVAS_SCANNER_VERSION} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
    -DOPENVAS_RUN_DIR=/run/ospd \
    && make -j$(nproc) \
    && make DESTDIR=${INSTALL_DIR} install

FROM base AS build_ospd_openvas
ARG OSPD_OPENVAS_VERSION
ENV OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION}
COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
# Download and install ospd-openvas
RUN curl -sSL https://github.com/greenbone/ospd-openvas/archive/refs/tags/v${OSPD_OPENVAS_VERSION}.tar.gz -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/ospd-openvas/releases/download/v${OSPD_OPENVAS_VERSION}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz \
    && cd ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION} \
    && python3 -m pip install . --prefix=${INSTALL_PREFIX} --root=${INSTALL_DIR} --no-warn-script-location
# maybe also:    && python3 -m pip install . --no-warn-script-location


FROM debian:11-slim AS latest
ARG POSTGRESQL_VERSION
ARG GSAD_VERSION
ARG GSA_VERSION
ARG GVM_LIBS_VERSION
ARG GVMD_VERSION
ARG OPENVAS_SCANNER_VERSION
ARG OPENVAS_SMB_VERSION
ARG PYTHON_GVM_VERSION
ARG OSPD_OPENVAS_VERSION
ARG GVM_TOOLS_VERSION

ARG SETUP=0
ARG OPT_PDF=0

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

ENV POSTGRESQL_VERSION=${POSTGRESQL_VERSION} \
    GSAD_VERSION=${GSAD_VERSION} \
    GSA_VERSION=${GSA_VERSION} \
    GVM_LIBS_VERSION=${GVM_LIBS_VERSION} \
    GVMD_VERSION=${GVMD_VERSION} \
    OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION} \
    OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION} \
    PYTHON_GVM_VERSION=${PYTHON_GVM_VERSION} \
    OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION} \
    GVM_TOOLS_VERSION=${GVM_TOOLS_VERSION} \
    SYSTEM_DIST=debian \
    SUPVISD=${SUPVISD:-supervisorctl} \
    USERNAME=${USERNAME:-${GVMD_USER:-admin}} \
    PASSWORD=${PASSWORD:-${GVMD_PASSWORD:-admin}} \
    PASSWORD_FILE=${PASSWORD_FILE:-${GVMD_PASSWORD_FILE:-none}} \
    TIMEOUT=${TIMEOUT:-15} \
    DEBUG=${DEBUG:-N} \
    RELAYHOST=${RELAYHOST:-smtp} \
    SMTPPORT=${SMTPPORT:-25} \
    AUTO_SYNC=${AUTO_SYNC:-YES} \
    AUTO_SYNC_ON_START=${AUTO_SYNC_ON_START:-YES} \
    HTTPS=${HTTPS:-true} \
    CERTIFICATE=${CERTIFICATE:-none} \
    CERTIFICATE_KEY=${CERTIFICATE_KEY:-none} \
    TZ=${TZ:-Etc/UTC} \
    SSHD=${SSHD:-false} \
    DB_PASSWORD=${DB_PASSWORD:-none} \
    DB_PASSWORD_FILE=${DB_PASSWORD:-none} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

COPY --from=build_gsa /install/ /
COPY --from=build_gsad /install/ /
COPY --from=build_gvm_libs /install/ /
COPY --from=build_gvmd /install/ /
COPY --from=build_openvas_smb /install/ /
COPY --from=build_openvas_scanner /install/ /
COPY --from=build_ospd_openvas /install/ /
COPY --from=build_openvas_scanner /source/openvas-scanner-${OPENVAS_SCANNER_VERSION}/config/redis-openvas.conf /etc/redis/redis-openvas.conf
COPY --from=build_openvas_scanner /source/openvas-scanner-${OPENVAS_SCANNER_VERSION}/config/redis-openvas.conf /opt/setup/redis-openvas.conf.openvas_scanner_source

ENTRYPOINT [ "/opt/setup/scripts/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

COPY config /opt/setup/config/
COPY scripts /opt/setup/scripts/

RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && \
    echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"'>>/etc/environment && \
    sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile && \
    ldconfig && \
    chmod -R +x /opt/setup/scripts/*.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        coreutils \
        ca-certificates \
        gnupg \
        sudo \
        wget \
        lsb-release \
        curl && \
    echo "Acquire::http::Proxy \"${http_proxy}\";" | tee /etc/apt/apt.conf.d/30proxy && \
    echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" | tee /etc/apt/apt.conf.d/10no-recommend-installs && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list && \
    echo "deb http://deb.debian.org/debian `lsb_release -cs`-backports main" | tee /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dpkg \
        fakeroot \
        gnutls-bin \
        gosu \
        gpgsm \
        libglib2.0-0 \
        libgnutls30 \
        libgpgme11 \
        libhiredis0.14 \
        libical3 \
        libgssapi3-heimdal \
        libhdb9-heimdal \
        libldap-2.4-2 \
        libmicrohttpd12 \
        libnet1 \
        libpaho-mqtt1.3 \
        libpcap0.8 \
        libpq5 \
        libradcli4 \
        libssh-gcrypt-4 \
        libuuid1 \
        libxml2 \
        openssh-client \
        postfix \
        python3 \
        python3-cffi \
        python3-defusedxml \
        python3-deprecated \
        python3-impacket \
        python3-lxml \
        python3-packaging \
        python3-paho-mqtt \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        python3-redis \
        python3-setuptools \
        python3-wrapt \
        redis/bullseye-backports \
        rpm \
        smbclient \
        snmp \
        socat \
        sshpass \
        sudo \
        supervisor \
        xml-twig-tools \
        xmlstarlet \
        xsltproc \
        zip  \
        cron openssh-server nano \
        xz-utils \
        "postgresql-${POSTGRESQL_VERSION}" \
        "postgresql-common" \
        "postgresql-client-${POSTGRESQL_VERSION}" locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    python3 -m pip install --upgrade "ospd_openvas==${OSPD_OPENVAS_VERSION}" && \
    python3 -m pip install --upgrade "gvm-tools==${GVM_TOOLS_VERSION}" && \
    python3 -m pip install --upgrade "python-gvm==${PYTHON_GVM_VERSION}" && \
    useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm && \
    usermod -aG tty gvm  && \
    usermod -aG sudo gvm && \
    usermod -aG gvm redis && \
    mkdir /run/redis && \
    chown redis:gvm /run/redis && \
    mkdir -p /run/gvmd && \
    mkdir -p /var/lib/gvm && \
    mkdir -p /var/log/gvm && \
    chgrp -R gvm /etc/openvas/ && \
    chown -R gvm:gvm /etc/gvm && \
    chown -R gvm:gvm /run/gvmd && \
    chown -R gvm:gvm /var/lib/gvm && \
    chown -R gvm:gvm /var/log/gvm && \
    mkdir -p /run/gsad && \
    mkdir -p /var/log/gvm && \
    chown -R gvm:gvm /run/gsad && \
    chown -R gvm:gvm /var/log/gvm && \
    apt-get purge --auto-remove -yq *-dev *-dev-all *-dev-"${POSTGRESQL_VERSION}" && \
    apt-get clean all && \
    apt-get -yq autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    (rm /etc/apt/apt.conf.d/30proxy || true)
RUN update-alternatives --install /usr/bin/postgres postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/postgres 100 && \
    update-alternatives --install /usr/bin/initdb initdb /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/initdb 100
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/var/lib/gvm" ]



FROM latest AS latest-full
ARG SETUP=0
ARG OPT_PDF=1

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
        texlive-fonts-recommended \
        texlive-latex-extra

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"


FROM latest AS latest-data
ARG SETUP=1
ARG OPT_PDF=0

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SETUP=${SETUP} \
    OPT_PDF=${OPT_PDF}

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime &&  \
    echo "$TZ" >/etc/timezone && \
    /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf

ENV SETUP=0

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]

FROM latest-data AS latest-data-full

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
    unset OPT_PDF

RUN set -eu; \
    rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"

VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
