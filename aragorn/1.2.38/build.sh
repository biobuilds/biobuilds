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

# Assume the same signedess for plain chars across all compilers/platforms
CFLAGS="${CFLAGS} -fsigned-char"

# Fairly simple build/install process
mkdir -p "${PREFIX}/bin"
"${CC}" ${CFLAGS} ${LDFLAGS} \
    "${PKG_NAME}${PKG_VERSION}.c" \
    -o "${PREFIX}/bin/${PKG_NAME}"
chmod 755 "${PREFIX}/bin/${PKG_NAME}"
