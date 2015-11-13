#!/bin/bash
set -o pipefail

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

cp -f "${PREFIX}/share/autoconf/config.guess" config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config.sub
env CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="$PREFIX" \
    --enable-static --disable-shared \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
make check
make install
