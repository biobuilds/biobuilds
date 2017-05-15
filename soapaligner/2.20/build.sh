#!/bin/bash
set -o pipefail

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

[ -d "$PREFIX/bin" ] || mkdir -p "$PREFIX/bin"

if [[ "$BUILD_ARCH" == "x86_64" && "$BUILD_OS" == "Linux" ]]; then
    # Blindly assuming we're using gcc
    CFLAGS="${CFLAGS} -maccumulate-outgoing-args"
fi
if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
fi

# Make all compilers assume the older GCC (< 5.0) default language standard.
# Among other things, this prevents link-time "undefined symbol" errors caused
# by differences in C "inline" semantics.
CC="${CC} -std=gnu89"

## Build
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${MAKE_JOBS} CC="${CC}" PTHREADS=YES

## Install
cp -fvp soap "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/soap"
