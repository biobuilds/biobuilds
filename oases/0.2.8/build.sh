#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Should be provided by "velvet" package
[ -d "${PREFIX}/include/velvet" ] || \
    { echo "ERROR: could not find velvet headers" >&2; exit 1; }

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -I${PREFIX}/include/velvet"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"


# Build
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} OPENMP=1 \
    MAXKMERLENGTH=64 LONGSEQUENCES=1 \
    oases


# Install
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
cp -p oases "${PREFIX}/bin"
