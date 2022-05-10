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

FROM debian:11-slim as base
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

RUN set -eu; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https; \
	cp /opt/context-full/helper/config/apt-source.list /etc/apt/sources.list

RUN set -e; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN set -eu; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN set -eu; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libnss-wrapper \
		xz-utils \
		zstd \
	; \
	rm -rf /var/lib/apt/lists/*


RUN set -e; \
    cat /aptrepo/apt.github.deineagentur.com.gpg.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.github.deineagentur.com.gpg >/dev/null

RUN set -e; \
    echo "deb [ signed-by=/etc/apt/trusted.gpg.d/apt.github.deineagentur.com.gpg ] file:///aptrepo/ bullseye main" > /etc/apt/sources.list.d/temp.list; \
    apt-get -o Acquire::GzipIndexes=false update;

ENV PATH $PATH:/usr/lib/postgresql/$POSTGRESQL_VERSION/bin

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
    && apt-get update \
    && apt-get -yq upgrade \
    && apt-get install -y --no-install-recommends "postgresql-common"; \
	sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf; \
    apt-get -yq --no-install-recommends install "postgresql-${POSTGRESQL_VERSION}" "postgresql-server-dev-${POSTGRESQL_VERSION}"


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
