#!/bin/bash

set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

env CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
    ./configure --prefix="${PREFIX}" \
    --disable-werror \
    --enable-static \
    --enable-shared \
    --with-x \
    --without-libiconv-prefix \
    --with-zlib \
    --with-png \
    --with-freetype \
    --without-fontconfig \
    --with-jpeg \
    --without-liq \
    --without-xpm \
    --with-tiff \
    --without-webp \
    2>&1 | tee configure.log


## Build and install
make -j${BB_MAKE_JOBS} V=1 2>&1 | tee build.log
make install 2>&1
