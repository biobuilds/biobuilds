#!/bin/bash
set -e -x
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Assume the same signedness for plain chars across all compilers/platforms.
# (Based on the default for x86_64 gcc.)
CFLAGS="${CFLAGS} -fsigned-char"

make -j${MAKE_JOBS:-1} \
    CC="${CC}" \
    CFLAGS="${CFLAGS} -Wall -pedantic" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log

make INSTALLDIR="${PREFIX}/bin" install
