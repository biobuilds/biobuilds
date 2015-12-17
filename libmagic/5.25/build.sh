#!/bin/bash

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

./configure --prefix="${PREFIX}" \
    --enable-shared --disable-static \
    --enable-largefile \
    2>&1 | tee configure.log
make
make check
make install
