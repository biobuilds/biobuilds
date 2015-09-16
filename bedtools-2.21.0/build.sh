#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

# configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# make
env CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make -j${BB_MAKE_JOBS}
env CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make test

# install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp -R "${SRC_DIR}/bin/." "${PREFIX}/bin"
