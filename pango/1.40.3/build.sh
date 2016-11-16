#!/bin/bash

[ -d "${PREFIX}/lib" ] && mkdir -p "${PREFIX}/lib"

ln -sfn "${PREFIX}/lib" "${PREFIX}/lib64"

env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    ./configure --prefix="${PREFIX}" \
        --enable-shared \
        --enable-static \
        --disable-gtk-doc \
        --disable-gtk-doc-html \
        --disable-gtk-doc-pdf \
        --without-xft \
        --with-cairo \
        2>&1 | tee configure.log

make -j${CPU_COUNT} V=1

env LD_LIBRARY_PATH="${PREFIX}/lib" \
    DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    make check V=1

make install
rm -f "${PREFIX}/lib64"
rm -rf "${PREFIX}/share/gtk-doc" "${PREFIX}/share/man"
