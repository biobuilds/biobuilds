#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Should be provided by "velvet" package
[ -d "${PREFIX}/include/velvet" ] || \
    { echo "ERROR: could not find velvet headers" >&2; exit 1; }
CFLAGS="${CFLAGS} -I${PREFIX}/include/velvet"

# Build
env CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} OPENMP=1 \
    MAXKMERLENGTH=64 LONGSEQUENCES=1 \
    oases


# Install
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
cp -p oases "${PREFIX}/bin"
