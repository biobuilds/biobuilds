#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

make -j${MAKE_JOBS} \
    CC="${CC}" \
    CFLAGS="-Wall ${CFLAGS}" \
    LD="${CC}" \
    LDFLAGS="${LDFLAGS}" \
    AR="${AR}" \
    all-recur

# "lib-recur" dummy dependency for "samtools" triggers re-linking, so we
# need to make sure LDFLAGS are provided to "install" target.
make -j${MAKE_JOBS} \
    PREFIX="${PREFIX}" \
    CC="${CC}" \
    CFLAGS="-Wall ${CFLAGS}" \
    LD="${CC}" \
    LDFLAGS="${LDFLAGS}" \
    AR="${AR}" \
    install-recur
