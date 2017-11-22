#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }
CFLAGS="${CFLAGS} $(pkg-config --cflags-only-I htslib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L htslib)"

## Build and install
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    HTSLIB_INCLUDE_DIR="${PREFIX}/include" \
    HTSLIB_LIBRARY_DIR="${PREFIX}/lib" \
    "$PYTHON" setup.py install
