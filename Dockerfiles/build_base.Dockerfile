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

FROM debian:11-slim as base

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
    LANG=C.UTF-8

RUN echo ${PATH}

RUN apt-get update \
    && apt-get -yq upgrade \
    && apt-get install -yq \
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
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get -yq upgrade \
    && apt-get -yq install \
      postgresql-${POSTGRESQL_VERSION} \
      postgresql-server-dev-${POSTGRESQL_VERSION} \
      postgresql-client-${POSTGRESQL_VERSION} \
      postgresql-common \
      postgresql-client-common


# Install required dependencies for gvm-libs
RUN apt-get install -yq \
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
