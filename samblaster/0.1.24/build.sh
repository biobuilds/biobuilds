#!/bin/bash
set -o pipefail

# Configure
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

CFLAGS="${CFLAGS} -fsigned-char"

# BUILDNUM define that we'll squash by passing CCFLAGS directly to make
BUILDNUM=`echo "$PKG_VERSION" | cut -d. -f3`
CFLAGS="${CFLAGS} -DBUILDNUM=${BUILDNUM}"

# Squash some messages about asprintf() return values
CFLAGS="${CFLAGS} -Wall -Wno-unused-result"

make CC="${CC}" CPP="${CXX}" CCFLAGS="${CFLAGS}" 2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
install -m 0755 samblaster "${PREFIX}/bin"
