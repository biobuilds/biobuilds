#!/bin/bash

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub

./configure --prefix="$PREFIX"
make
make install
