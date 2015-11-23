#!/bin/bash

cp -fv "${PREFIX}/share/autoconf/config.guess" config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" config.sub

./configure --prefix="$PREFIX" \
    --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
    2>&1 | tee configure.log

make -j${CPU_COUNT}
make check

make install
rm -rf "${PREFIX}/share/gtk-doc"
