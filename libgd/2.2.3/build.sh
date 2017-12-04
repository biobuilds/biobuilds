#!/bin/bash

set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

env CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
    ./configure --prefix="${PREFIX}" \
    --disable-werror \
    --enable-static \
    --enable-shared \
    --with-x \
    --without-libiconv-prefix \
    --with-zlib \
    --with-png \
    --with-freetype \
    --without-fontconfig \
    --with-jpeg \
    --without-liq \
    --without-xpm \
    --with-tiff \
    --without-webp \
    2>&1 | tee configure.log


## Build and install
make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make install 2>&1
