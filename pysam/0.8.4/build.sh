#!/bin/bash

## Compile configuration
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }
CFLAGS="${CFLAGS} $(pkg-config --cflags-only-I htslib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L htslib)"

## Build and install
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    HTSLIB_INCLUDE_DIR="${PREFIX}/include" \
    HTSLIB_LIBRARY_DIR="${PREFIX}/lib" \
    "$PYTHON" setup.py install
