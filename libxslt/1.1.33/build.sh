#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

./configure --prefix="${PREFIX}" \
    --enable-shared \
    --enable-static \
    --with-pic \
    --without-debug \
    --without-mem-debug \
    --without-debugger \
    --without-html-dir \
    --with-crypto \
    --without-python \
    2>&1 | tee configure.log
make -j${MAKE_JOBS} ${VERBOSE_AT} \
    2>&1 | tee build.log
make check
make install
