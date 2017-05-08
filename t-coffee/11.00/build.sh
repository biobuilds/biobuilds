#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ "$BUILD_ARCH" == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -fsigned-char"
fi

# Squash "deprecated conversion from string constant to 'char*'" warnings
CFLAGS="-Wno-write-strings ${CFLAGS}"

# Make sure all perl scripts are executable; needed since files from the GitHub
# tarballs don't always have the right permissions, and the build process needs
# some of these scripts to run correctly.
find . -name '*.pl' | xargs chmod 0755

# Build
cd compile
make VERSION="${PKG_VERSION}" OPENMP=1 \
    CC="${CXX}" CFLAGS="${CFLAGS}" \
    t_coffee

# Install
install -d "${PREFIX}/bin"
install -m 0755 t_coffee "${PREFIX}/bin"
