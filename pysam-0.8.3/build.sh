#!/bin/bash

## Compile configuration
command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags-only-I zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"


## Build and install
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    "$PYTHON" setup.py install
