# syntax=docker/dockerfile:1.4

FROM debian:11-slim

ENTRYPOINT [ "/opt/setup/scripts/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

COPY config /opt/setup/
COPY scripts /opt/setup/scripts/
RUN chmod -R +x /opt/setup/scripts/*.sh
#RUN bash /opt/setup/debian/install-pkgs.sh

# gvmd: v21.4.3
# gsa: v21.4.2
# gvm-libs: v21.4.2
# gvm-tools: v21.6.1
# ospd: v21.4.3
# ospd-openvas: v21.4.2
# openvas-scanner: v21.4.2
# openvas-smb: v21.4.0
# python-gvm: v21.6.0

ARG POSTGRESQL_VERSION="13"
ARG GVM_LIBS_VERSION="21.4.4"
ARG PGGVM_VERSION="da7bef426089e63da80fe85b723ce01714810871"
ARG GVMD_VERSION="21.4.5"
ARG GSA_VERSION="21.4.4"
ARG GSAD_VERSION="21.4.4"
ARG GVM_TOOLS_VERSION="21.10.0"
ARG OPENVAS_SMB_VERSION="21.4.0"
ARG OPENVAS_SCANNER_VERSION="21.4.4"
ARG OSPD_OPENVAS_VERSION="21.4.4"
ARG PYTHON_GVM_VERSION="21.11.0"

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
    GVM_LIBS_VERSION=${GVM_LIBS_VERSION} \
    PGGVM_VERSION=${PGGVM_VERSION} \
    GVMD_VERSION=${GVMD_VERSION} \
    GSA_VERSION=${GSA_VERSION} \
    GSAD_VERSION=${GSAD_VERSION} \
    GVM_TOOLS_VERSION=${GVM_TOOLS_VERSION} \
    OPENVAS_SMB_VERSION=${OPENVAS_SMB_VERSION} \
    OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION} \
    OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION} \
    PYTHON_GVM_VERSION=${PYTHON_GVM_VERSION} \
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
    DB_PASSWORD_FILE=${DB_PASSWORD:-none}

RUN apt-get update && apt-get install -y locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN ls -lahR /opt/setup/
RUN /opt/setup/scripts/debian/prepare.sh
RUN /opt/setup/scripts/debian/main_pkgs.sh

#COPY report_formats/* /report_formats/

# COPY greenbone-feed-sync-patch.txt /greenbone-feed-sync-patch.txt

# RUN patch /usr/local/sbin/greenbone-feed-sync /greenbone-feed-sync-patch.txt

ARG SETUP=0
ARG OPT_PDF=0
ENV SETUP=${SETUP:-0} \
    OPT_PDF=${OPT_PDF:-0}

RUN env \
    && chmod -R +x /opt/setup/scripts/*.sh
RUN if [ "${SETUP}" = "1" ]; then \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone \
    && /opt/setup/scripts/entrypoint.sh /usr/bin/supervisord -c /etc/supervisord.conf || true ; \
    unset SETUP ;\
    fi
RUN if [ "${OPT_PDF}" = "1" ]; then \
    sudo apt update ;\
    sudo apt install -y --no-install-recommends texlive-latex-extra texlive-fonts-recommended ;\
    unset OPT_PDF ;\
    fi
RUN rm -rfv /var/lib/gvm/CA || true \
    && rm -rfv /var/lib/gvm/private || true \
    && rm /etc/localtime || true\
    && echo "Etc/UTC" >/etc/timezone \
    && rm -rfv /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && echo "!!! FINISH Setup !!!"
ENV SETUP=0





VOLUME [ "/opt/database", "/var/lib/openvas/plugins", "/var/lib/gvm", "/etc/ssh" ]
