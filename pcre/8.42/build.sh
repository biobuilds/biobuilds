#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Make sure the static libraries (*.a) are usuable for building dependent
# shared libraries (*.so/*.dylib).
CFLAGS="${CFLAGS} -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC"

export CC CFLAGS CXX CXXFLAGS AR LD LDFLAGS

./configure --prefix="${PREFIX}"  \
    --enable-shared \
    --enable-static \
    --enable-cpp \
    --enable-jit \
    --enable-pcregrep-jit \
    --enable-pcregrep-libz \
    --enable-pcregrep-libbz2 \
    --enable-pcre8 \
    --enable-pcre16 \
    --enable-pcre32 \
    --enable-utf \
    --enable-unicode-properties \
    --disable-ebcdic \
    --enable-newline-is-any \
    --enable-bsr-anycrlf \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT} 2>&1 | tee build.log
make check

make install
rm -rf "${PREFIX}"/share/man/man3/pcre* "${PREFIX}"/share/doc/pcre
