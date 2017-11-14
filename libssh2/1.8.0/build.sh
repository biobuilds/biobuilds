#!/bin/bash

set -o pipefail

export CFLAGS="${CFLAGS} -m64 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -fv "${PREFIX}/share/autoconf/config.guess" config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" config.sub

./configure --prefix="${PREFIX}" \
    --disable-debug \
    --enable-shared \
    --enable-static \
    --enable-largefile \
    --disable-examples-build \
    --with-openssl \
    --with-libssl-prefix="${PREFIX}" \
    --with-libz \
    --with-libz-prefix="${PREFIX}" \
    --without-libgcrypt \
    --without-wincng \
    --without-libcrypt32-prefix \
    --without-libmbedtls-prefix \
    --without-libbcrypt-prefix \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}

# Skipping "make check" on OS X; something in the "conda build" process causes
# it to fail, even though we can come back later, "source activate" the conda
# build environment, run "make check", and have the tests pass. This gives us
# enough confidence that the built libraries will work as expected.
if [ `uname -s` != 'Darwin' ]; then
    make check
fi

make install
rm -rf "${PREFIX}/share/man"
