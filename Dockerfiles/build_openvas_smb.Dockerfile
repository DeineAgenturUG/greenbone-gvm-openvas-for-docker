
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
