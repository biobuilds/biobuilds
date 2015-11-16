#!/bin/bash

cp -fv "${PREFIX}/share/autoconf/config.guess" .
cp -fv "${PREFIX}/share/autoconf/config.sub" .

env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    ./configure --prefix="${PREFIX}" \
    --with-pic --with-python="${PREFIX}/bin/python" \
    --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
    --disable-man \
    --disable-selinux \
    --disable-fam \
    --disable-xattr \
    --disable-libelf \
    2>&1 | tee configure.log

make -j${CPU_COUNT}

make install
rm -rf "${PREFIX}/share/gtk-doc" "${PREFIX}/share/bash-completion"
