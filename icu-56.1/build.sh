#!/bin/bash

cd source
CFLAGS="${CFLAGS} -O3"
CXXFLAGS="${CXXFLAGS} -O3"

if [ `uname -s` == 'Darwin' ]; then
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LDFLAGS="${LDFLAGS} -stdlib=libstdc++"
fi

env CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="$PREFIX" --disable-debug --enable-release \
    --enable-shared --disable-static --enable-rpath
make
make install
