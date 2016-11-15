#!/bin/bash

set -o pipefail

./configure --prefix="${PREFIX}" \
    --enable-shared --enable-static \
    --disable-gtk-doc \
    --disable-gtk-doc-html \
    --disable-gtk-doc-pdf \
    --without-libiconv-prefix \
    2>&1 | tee configure.log

make
make check
make install

# Save some space
rm -rf "${PREFIX}/share/info"
rm -rf "${PREFIX}/share/man"
rm -rf "${PREFIX}/share/gtk-doc"
