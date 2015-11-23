#!/bin/bash

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub
sed -i "s,@PREFIX@,${PREFIX}," src/fccfg.c
./configure --prefix="${PREFIX}" \
    --enable-libxml2

make

make install
rm -rf "${PREFIX}/share/doc" "${PREFIX}/share/man"
rm -rf "${PREFIX}/var"
