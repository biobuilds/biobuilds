#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Configure
rm -rf src/zlib     # force use of the zlib we provide

# Build
make -j${MAKE_JOBS} V=1 \
    CXX="${CXX}" \
    CXXFLAGS="-std=c++11 ${CXXFLAGS}" \
    LD_FLAGS="-lz -lpthread ${LDFLAGS}"

# Install
install -m 755 -d "${PREFIX}/bin"
install -m 755 fastp "${PREFIX}/bin"
