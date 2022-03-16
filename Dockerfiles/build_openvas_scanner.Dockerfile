
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
