#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Configure
build_arch=$(uname -m)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ "$build_arch" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
    CFLAGS="${CFLAGS} -fsigned-char"
elif [ "$build_arch" != "x86_64" ]; then
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

# Build
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS} all

# Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp -p -f "${SRC_DIR}/bwa" "${PREFIX}/bin"
