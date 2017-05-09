#!/bin/bash

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

cp -fv "${PREFIX}/share/autoconf/config.guess" "config.guess"
cp -fv "${PREFIX}/share/autoconf/config.sub" "config.sub"

env CC="${CC}" CFLAGS="${CFLAGS}" \
    ./configure --prefix="${PREFIX}" \
        --enable-shared \
        --disable-static \
        --with-pic \
        2>&1 | tee configure.log


## Make
make
make check


## Install
make install
rm -rfv "${PREFIX}/share/doc/${PKG_NAME}"
