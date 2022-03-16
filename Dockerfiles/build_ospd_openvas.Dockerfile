
FROM base AS build_ospd_openvas
ARG OSPD_OPENVAS_VERSION
ENV OSPD_OPENVAS_VERSION=${OSPD_OPENVAS_VERSION}
COPY --from=build_gvm_libs /install/ /
RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
# Download and install ospd-openvas
RUN curl -sSL https://github.com/greenbone/ospd-openvas/archive/refs/tags/v${OSPD_OPENVAS_VERSION}.tar.gz -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz \
    && curl -sSL https://github.com/greenbone/ospd-openvas/releases/download/v${OSPD_OPENVAS_VERSION}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc -o ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc \
    && gpg --verify ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz.asc ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz

RUN tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION}.tar.gz \
    && cd ${SOURCE_DIR}/ospd-openvas-${OSPD_OPENVAS_VERSION} \
    && python3 -m pip install . --prefix=${INSTALL_PREFIX} --root=${INSTALL_DIR} --no-warn-script-location
# maybe also:    && python3 -m pip install . --no-warn-script-location

