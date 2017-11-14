#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ `uname -s` == "Linux" ]; then
    CFLAGS="${CFLAGS} -fPIC"
    CXXFLAGS="${CXXFLAGS} -fPIC"
fi

export CC CFLAGS CXX CXXFLAGS LD LDFLAGS

./configure --prefix="${PREFIX}"  \
    --enable-shared \
    --enable-static \
    --enable-jit \
    --enable-pcregrep-libz \
    --enable-pcregrep-libbz2 \
    --enable-utf \
    --enable-unicode-properties \
    --enable-pcre8 \
    --enable-pcre16 \
    --enable-pcre32 \
    2>&1 | tee configure.log
make -j${CPU_COUNT} ${VERBOSE_AT} 2>&1 | tee build.log
make check

make install
rm -rf "${PREFIX}/share"
