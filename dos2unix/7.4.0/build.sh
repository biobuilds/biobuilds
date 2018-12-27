#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_OS" in
    "darwin")
        LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        ;;
    "linux")
        LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        ;;
esac

make bin-only \
    CC="${CC}" CFLAGS_USER="${CFLAGS}" \
    LD="${LD}" LDFLAGS_USER="${LDFLAGS}"
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check-bin
make install-bin prefix="${PREFIX}"
