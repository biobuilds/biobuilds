#!/bin/bash

cp -fv "${PREFIX}/share/autoconf/config.guess" .
cp -fv "${PREFIX}/share/autoconf/config.sub" .

[ -d "${PREFIX}/lib" ] && mkdir -p "${PREFIX}/lib"
ln -sfn "${PREFIX}/lib" "${PREFIX}/lib64"
./configure --prefix="${PREFIX}" \
    --disable-man --disable-gtk-doc \
    --disable-gtk-doc-html --disable-gtk-doc-pdf \
    --without-xft --with-cairo \
    2>&1 | tee configure.log

make -j$CPU_COUNT

make install

rm -f "${PREFIX}/lib64"
rm -rf "${PREFIX}/share/gtk-doc" "${PREFIX}/share/man"
