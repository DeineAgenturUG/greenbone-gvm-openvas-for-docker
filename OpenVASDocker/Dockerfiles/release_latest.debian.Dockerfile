# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/openvas-scanner
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

FROM ${CACHE_BUILD_IMAGE}:build_gvm_libs AS build_gvm_libs
#FROM ${CACHE_BUILD_IMAGE}:build_openvas_smb AS build_openvas_smb
FROM ${CACHE_BUILD_IMAGE}:build_openvas_scanner AS build_openvas_scanner

FROM debian:11-slim
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
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

COPY --from=build_gvm_libs / /
#COPY --from=build_openvas_smb / /
COPY --from=build_openvas_scanner / /

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=bind,source=./,target=/opt/context/,rw \
    --mount=type=cache,mode=0755,sharing=locked,target=/var/cache/apt  \
    --mount=type=cache,mode=0755,sharing=locked,target=/root/.cache/pip \
    /opt/context/build.sh


ENTRYPOINT ["/opt/setup/scripts/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
