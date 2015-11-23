#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }


## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

env CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="$PREFIX"


## Build
make -j${BB_MAKE_JOBS}
env LD_LIBRARY_PATH="${PREFIX}/lib" DYLD_LIBRARY_PATH="${PREFIX}/lib" \
    make test


## Install
make install
