#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} -DNDEBUG -fopenmp -Wall -Wno-deprecated"
CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

CPU_ARCH=$(uname -m)
if [ "$CPU_ARCH" == "ppc64le" ]; then
    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CXXFLAGS="-I${PREFIX}/include/veclib ${CXXFLAGS}"
fi


# Build
env CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    make -j${BB_MAKE_JOBS}


## Install
env PREFIX="${PREFIX}" make install
