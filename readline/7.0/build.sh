#!/usr/bin/env bash
set -u -o pipefail

./configure --prefix="${PREFIX}"  \
    --enable-multibyte \
    --enable-shared \
    --enable-static \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT} \
    SHLIB_LIBS="$(pkg-config --libs-only-l tinfo)" \
    2>&1 | tee build.log

make install
