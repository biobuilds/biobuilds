#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Standard autotools build process
./configure --prefix="$PREFIX" \
    --with-pic \
    --enable-shared \
    --disable-static \
    --enable-rpath \
    --disable-debug \
    --enable-memory-mapped-io \
    --disable-libgdbm-compat \
    --enable-largefile \
    --enable-nls \
    --without-readline \
    2>&1 | tee configure.log
make -j${MAKE_JOBS} ${VERBOSE_AT}
make install
