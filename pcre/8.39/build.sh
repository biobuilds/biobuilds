#!/bin/bash
set -e -x -o pipefail

build_os=`uname -s`
build_arch=`uname -m`

if [ "$build_os" == "Linux" ]; then
    CFLAGS="${CFLAGS} -fPIC"
    CPPFLAGS="${CPPFLAGS} -fPIC"
fi

# Assume target platforms will be 64-bit (reasonable for BioBuilds)
CFLAGS="${CFLAGS} -m64"

if [ "$build_arch" == "ppc64le" ]; then
    CFLAGS="${CFLAGS} -mcpu=power8 -mtune=power8"
    CFLAGS="${CFLAGS} -maltivec -mvsx"
elif [ "$build_arch" == "x86_64" ]; then
    # The most "basic" 64-bit Intel architecture
    CFLAGS="${CFLAGS} -mcpu=nocona -mtune=nocona"
else
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

# No C++-specific flags needed, so just carry CFLAGS over
CXXFLAGS="${CFLAGS}"

# Set these so PCRE picks up support for gzip and bzip2 files
# (For some reason, pkg-config does not work with this ./configure.)
CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
./configure --prefix="${PREFIX}" \
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

make -j${CPU_COUNT} V=1 2>&1 | tee build.log
make check

make install
rm -rf "${PREFIX}/share/doc/pcre"
rm -rf "${PREFIX}/share/man/man3"
