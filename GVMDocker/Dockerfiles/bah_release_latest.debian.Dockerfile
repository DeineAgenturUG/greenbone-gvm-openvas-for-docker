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


FROM ${CACHE_BUILD_IMAGE}:build_gsad AS build_gsad
FROM ${CACHE_BUILD_IMAGE}:build_gvm_libs AS build_gvm_libs
FROM ${CACHE_BUILD_IMAGE}:build_gvmd AS build_gvmd
FROM ${CACHE_BUILD_IMAGE}:build_openvas_scanner AS build_openvas_scanner

FROM debian:11-slim AS latest
ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
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
    SETUP=0 \
    OPT_PDF=0

COPY --from=build_gsad / /
COPY --from=build_gvm_libs / /
COPY --from=build_gvmd / /
COPY --from=build_openvas_scanner / /

ENTRYPOINT [ "/opt/setup/scripts/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

COPY config /opt/setup/config/
COPY scripts /opt/setup/scripts/

RUN set -eu; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https; \
	cp /opt/context-full/helper/config/apt-source.list /etc/apt/sources.list

RUN /opt/context/build/build_latest.sh
