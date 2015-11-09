#!/bin/bash

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

[ -d "${PREFIX}/bin" ] && mkdir -p "${PREFIX}/bin"

# Build
rm -f source/makefile
env CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
    make -j${BB_MAKE_JOBS} \
    PREFIX="${PREFIX}" 64BIT_VERSION=yes \
    BOOST_INCLUDE_DIR="${PREFIX}/include" \
    BOOST_LIBRARY_DIR="${PREFIX}/lib" \
    FORTRAN_FLAGS="-bogus" \
    USEBOOST=yes \
    USECOMPRESSION=yes \
    USEMPI=no \
    USERREADLINE=yes


# Install
cp mothur "${PREFIX}/bin"
cp uchime "${PREFIX}/bin"
