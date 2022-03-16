
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
