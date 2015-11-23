#!/bin/bash
set -o pipefail

if [ `uname` == Linux ]; then
    CFLAGS="${CFLAGS} -fPIC"
    CPPFLAGS="${CPPFLAGS} -fPIC"
fi

# Assume target platforms will be 64-bit (reasonable for BioBuilds)
CFLAGS="${CFLAGS} -m64"

# Can be a bit more aggressive with POWER optimizations since this ecosystem
# has far fewer variations than the x86_64 world
if [ `uname -m` == "ppc64le" ]; then
    CFLAGS="${CFLAGS} -mcpu=power8 -mtune=power8"
    CFLAGS="${CFLAGS} -maltivec -mvsx"
fi

# Set these so PCRE picks up support for gzip and bzip2 files
CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS CPPFLAGS LDFLAGS
./configure --prefix="${PREFIX}" \
    --enable-shared --enable-static \
    --enable-jit --enable-pcregrep-libz --enable-pcregrep-libbz2 \
    --enable-utf --enable-unicode-properties \
    --enable-pcre16 --enable-pcre32 \
    2>&1 | tee configure.log
make V=1
make install
