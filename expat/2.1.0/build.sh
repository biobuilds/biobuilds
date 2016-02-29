#!/bin/bash

cp -f "${PREFIX}/share/autoconf/config.guess" "conftools/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "conftools/config.sub"

./configure --prefix="$PREFIX"
make
make install
