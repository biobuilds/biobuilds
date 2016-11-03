#!/bin/sh

cp -fv "${PREFIX}/share/autoconf/config.guess" build-aux/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" build-aux/config.sub

./configure --prefix="$PREFIX"
make
make install
