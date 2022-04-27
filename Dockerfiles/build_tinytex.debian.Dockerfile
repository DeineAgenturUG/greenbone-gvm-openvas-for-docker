# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

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
ARG TINYTEX_VERSION="2022.04.04"

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
    INSTALL_DIR=${INSTALL_DIR} \
    DESTDIR=${DESTDIR}

ARG TINYTEX_VERSION
ENV TINYTEX_VERSION=${TINYTEX_VERSION}
SHELL ["/bin/bash", "-c"]
# Download and install gvm-libs
RUN set -x && cd /root/ && wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh -s -- --admin --no-path \
    && chown -R root:staff /root/.TinyTeX \
    && chmod -R g+w /root/.TinyTeX \
    && chmod -R g+wx /root/.TinyTeX/bin
RUN set -x && mv /root/.TinyTeX /opt/tinytex \
    && sed -i 's#/root/.TinyTeX#/opt/tinytex#g' /opt/tinytex/texmf-var/fonts/conf/texlive-fontconfig.conf
RUN set -x && sudo /opt/tinytex/bin/*/tlmgr path add \
    && /opt/tinytex/bin/*/tlmgr update --self --all \
    && /opt/tinytex/bin/*/tlmgr install changepage colortbl comment grfext grffile oberdiek titlesec ucs \
    && /opt/tinytex/bin/*/fmtutil-sys --all

RUN grep -r ".TinyTeX" /etc/ /opt/ /usr/ /lib/ || true
RUN grep -r "/root/" /opt/tinytex/ || true
RUN grep -r "<dir>" /opt/tinytex/ || true


#FROM scratch
#ARG CACHE_IMAGE
#ARG CACHE_BUILD_IMAGE
#ARG INSTALL_PREFIX
#ARG SOURCE_DIR
#ARG BUILD_DIR
#ARG INSTALL_DIR
#ARG DESTDIR

#COPY --from=build ${INSTALL_DIR} /
