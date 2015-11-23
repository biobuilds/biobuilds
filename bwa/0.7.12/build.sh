#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

CPU_ARCH=$(uname -m)
if [ "$CPU_ARCH" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
elif [ "$CPU_ARCH" != "x86_64" ]; then
    echo "ERROR: Unsupported architecture '$CPU_ARCH'" >&2
    exit 1
fi

# Build
env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make -j${BB_MAKE_JOBS} all

# Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp -p -f "${SRC_DIR}/bwa" "${PREFIX}/bin"
