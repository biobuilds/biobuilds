#!/bin/bash

cd source
env CFLAGS="-O3" CXXFLAGS="-O3" \
    ./configure --prefix="$PREFIX" --disable-debug --enable-release \
    --enable-shared --disable-static --enable-rpath
make
make install
