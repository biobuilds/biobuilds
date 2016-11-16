#!/bin/bash

env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
    CPPFLAGS="-I${PREFIX}/include" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
    ./configure --prefix="$PREFIX" \
        --enable-shared \
        --enable-static \
        --disable-gtk \
        --enable-libpng \
        2>&1 | tee configure.log
make V=1 -j${CPU_COUNT}
make check
make install
