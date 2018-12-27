#!/bin/bash
env

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

./configure --prefix="$PREFIX"
make -j${MAKE_JOBS} ${VERBOSE_AT}
make install
