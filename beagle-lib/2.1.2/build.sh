#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ "$build_arch" == 'x86_64' ]; then
    SSE_OPT="--enable-sse"

    # Needed to pick up conda's "ltdl.h" (GNU libtool header)
    CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
elif [ "$build_arch" == 'ppc64le' ]; then
    SSE_OPT="--disable-sse"

    # Needed to pick up get POWER8 vector intrinsics headers
    CPPFLAGS="-I${PREFIX}/include/veclib ${CPPFLAGS}"
fi

if [ "$build_os" == 'Darwin' ]; then
    # Need this or "./configure" and "make check" will fail
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

if [ ! -f ./configure ]; then
    ./autogen.sh 2>&1 | tee autogen.log
fi

env CPPFLAGS="${CPPFLAGS}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="$PREFIX" \
    --enable-static --enable-shared \
    --disable-osx-snowleopard \
    --disable-march-native \
    --enable-openmp \
    ${SSE_OPT} --disable-avx \
    --disable-phi --without-opencl \
    --without-cuda --enable-emu \
    --disable-doxygen-doc --without-jdk \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} V=1 2>&1 | tee build.log
make check 2>&1 | tee check.log


## Install
make install
