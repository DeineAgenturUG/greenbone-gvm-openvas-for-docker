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

ARG GVMD_VERSION
ARG POSTGRESQL_VERSION
ENV POSTGRESQL_VERSION=${POSTGRESQL_VERSION} \
    GVMD_VERSION=${GVMD_VERSION}

COPY --from=deineagenturug/gvm-build:build_gvm_libs / /
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


FROM scratch

ARG INSTALL_PREFIX
ARG SOURCE_DIR
ARG BUILD_DIR
ARG INSTALL_DIR
ARG DESTDIR

COPY --from=build ${INSTALL_DIR}/ /
