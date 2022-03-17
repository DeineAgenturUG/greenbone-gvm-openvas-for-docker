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

FROM deineagenturug/gvm-build:build_base AS build

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

ARG OPENVAS_SCANNER_VERSION
ENV OPENVAS_SCANNER_VERSION=${OPENVAS_SCANNER_VERSION}
COPY --from=deineagenturug/gvm-build:build_gvm_libs / /
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


FROM scratch

ARG INSTALL_PREFIX
ARG SOURCE_DIR
ARG BUILD_DIR
ARG INSTALL_DIR
ARG DESTDIR

COPY --from=build ${INSTALL_DIR}/ /
