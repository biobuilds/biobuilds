#!/bin/bash

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/config/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/config/config.sub"

# Force GNU89 inline semantics; otherwise, we'll end up with a bunch of
# undefined symbols when building.
if [[ $(gcc -v 2>&1 | grep -ci clang) -gt 0 ]]; then
    CFLAGS="${CFLAGS} -std=gnu89"
fi
if [[ $CC_IS_GNU ]]; then
    CFLAGS="${CFLAGS} -fgnu89-inline"
fi

env CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${LD}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-intel64 --enable-largefile \
    --disable-bzlib


## Build
make -j${MAKE_JOBS} all


## Install
make install
rm -f "${PREFIX}/bin/bfast.submit.pl" "${PREFIX}/bin/bfast.resubmit.pl"
