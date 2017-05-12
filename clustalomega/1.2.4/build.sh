#!/bin/bash


## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "${SRC_DIR}/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "${SRC_DIR}/config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    2>&1 | tee config.log


## Build and install
make -j${MAKE_JOBS} install
