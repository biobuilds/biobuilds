#!/bin/bash

[ -d "${PREFIX}/lib" ] || mkdir "$PREFIX/lib"

cp -f "${PREFIX}/share/autoconf/config.guess" "${SRC_DIR}/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "${SRC_DIR}/config.sub"
sh ./configure --prefix="$PREFIX" \
    --without-debug --without-ada --without-manpages \
    --with-shared --disable-overwrite --enable-termcap

make -j${CPU_COUNT}
make install
