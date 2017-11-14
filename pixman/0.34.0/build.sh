#!/bin/bash

BUILD_ARCH=`uname -m`
BUILD_OS=`uname -s`
OPTS=""

case "${BUILD_ARCH}" in
    x86_64)
        OPTS="${OPTS} --enable-mmx"
        OPTS="${OPTS} --enable-sse2"
        OPTS="${OPTS} --enable-ssse3"
        ;;
    ppc64le)
        # Not enabling because these may be the older, big-endian instructions
        #OPTS="${OPTS} --enable-vmx"
        ;;
    *)
        echo "Unsupported architecture '${BUILD_ARCH}'" >&2
        exit 1
        ;;
esac

case "${BUILD_OS}" in
    Linux)
        OPTS="${OPTS} --enable-openmp"
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        ;;
    Darwin)
        OPTS="${OPTS} --disable-openmp"
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        ;;
    *)
        echo "Unsupported operating system '${BUILD_OS}'" >&2
        exit 1
        ;;
esac

env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig" \
    CPPFLAGS="-I${PREFIX}/include" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
    ./configure --prefix="$PREFIX" \
        --enable-shared \
        --enable-static \
        --disable-gtk \
        --enable-libpng \
        $OPTS \
        2>&1 | tee configure.log
make ${VERBOSE_AT} -j${CPU_COUNT}
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
make install
