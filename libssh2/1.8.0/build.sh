#!/bin/bash

set -o pipefail

CFLAGS="${CFLAGS} -m64 -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -fv "${PREFIX}/share/autoconf/config.guess" config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" config.sub

env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --disable-debug \
    --enable-shared --enable-static \
    --enable-largefile \
    --disable-examples-build \
    --with-openssl \
    --with-libssl-prefix="${PREFIX}" \
    --with-libz \
    --with-libz-prefix="${PREFIX}" \
    --without-libgcrypt \
    --without-wincng \
    --without-libcrypt32-prefix \
    --without-mbedtls \
    --without-libmbedtls-prefix \
    --without-libbcrypt-prefix \
    2>&1 | tee configure.log

make

# Skipping "make check" on OS X; something in the "conda build" process causes
# it to fail, even though we can come back later, "source activate" the conda
# build environment, run "make check", and have the tests pass. This gives us
# enough confidence that the built libraries will work as expected.
if [ `uname -s` != 'Darwin' ]; then
    make check
fi

make install
rm -rf "${PREFIX}/share/man"
