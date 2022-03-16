
FROM base AS build_gvm_libs
ARG GVM_LIBS_VERSION
ENV GVM_LIBS_VERSION=${GVM_LIBS_VERSION}

# Download and install gvm-libs
RUN curl -sSL "https://github.com/greenbone/gvm-libs/archive/refs/tags/v${GVM_LIBS_VERSION}.tar.gz" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz" \
    && curl -sSL "https://github.com/greenbone/gvm-libs/releases/download/v${GVM_LIBS_VERSION}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" -o "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" \
    && gpg --verify "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz.asc" "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Unpack the gvm-libs tarball
RUN tar -C "${SOURCE_DIR}" -xvzf "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}.tar.gz"

# Build and install gvm-libs
RUN mkdir -p "${BUILD_DIR}/gvm-libs" && cd "${BUILD_DIR}/gvm-libs"
RUN cmake "${SOURCE_DIR}/gvm-libs-${GVM_LIBS_VERSION}" \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    && make "-j$(nproc)"\
    && make DESTDIR="${INSTALL_DIR}" install

