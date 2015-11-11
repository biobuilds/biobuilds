#!/bin/bash
set -o pipefail

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

build_os=$(uname -s)
build_arch=$(uname -m)

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"
CXXFLAGS="${CFLAGS}"

# Set (DY)LD_LIBRARY_PATH so ./configure works properly
if [ "$build_os" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
    # set this flag so clang treats C "inline" like gcc does
    CFLAGS="${CFLAGS} -std=gnu89"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# Tell the compiler where to find POWER8 veclib headers
if [ "$build_arch" == "ppc64le" ]; then
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CPPFLAGS="-I${PREFIX}/include/veclib ${CPPFLAGS}"
    CFLAGS="-I${PREFIX}/include/veclib ${CFLAGS}"
    CXXFLAGS="-I${PREFIX}/include/veclib ${CXXFLAGS}"
fi

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "config/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "config/config.sub"

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --disable-debug-functions --disable-perftools \
    --disable-intel64 --disable-32bit-support \
    --disable-tcmalloc \
    --disable-coloring \
    --enable-bz2 \
    --enable-adjacent-indels \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log


## Install
make install
rm -rf "${PREFIX}/share/doc"

# Rename binary to prevent conflict with EMBOSS "tmap" application
mv "${PREFIX}/bin/tmap" "${PREFIX}/bin/tmap-ion"
