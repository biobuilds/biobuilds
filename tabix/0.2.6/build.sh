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

# Force clang to use GNU-89 semantics for C "inline", or
# the build will fail with multiple undefined symbols.
if [[ $(gcc -v 2>&1 | grep -ci clang) -gt 0 ]]; then
    CFLAGS="${CFLAGS} -std=gnu89"
fi


## Build
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} all


## Install
env LDFLAGS="${LDFLAGS}" make PREFIX="$PREFIX" install
