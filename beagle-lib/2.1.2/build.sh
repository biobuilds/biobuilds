#!/bin/bash
set -o pipefail

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case "$BUILD_ARCH" in
    'x86_64')
        SSE_OPT="--enable-sse"

        # Needed to pick up conda's "ltdl.h" (GNU libtool header)
        CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
        ;;
    'ppc64le')
        SSE_OPT="--disable-sse"

        # Needed to pick up get POWER8 vector intrinsics headers
        CPPFLAGS="-I${PREFIX}/include/veclib ${CPPFLAGS}"
        ;;
esac

case "$BUILD_OS" in
    'darwin')
        # Need this or "./configure" and "make check" will fail
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        ;;
esac

# Make sure `javac` is available so we can build the JNI library.
#
# NOTE: Doing this because I haven't figure out what the value for configure's
# "--with-jdk" argument should be. So, we'll just have to trust ./configure to
# correctly pick up 'javac' from $PATH to build the JNI library.
JAVAC=`command -v javac 2>/dev/null`
if [ -z "$JAVAC" ]; then
    echo "FATAL: Could not find the Java compiler (javac)" >&2
    exit 1
fi

# Generate and run the "./configure" script
if [ ! -f ./configure ]; then
    ./autogen.sh 2>&1 | tee autogen.log
fi

env CPPFLAGS="${CPPFLAGS}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="$PREFIX" \
    --disable-static \
    --enable-shared \
    --disable-osx-snowleopard \
    --disable-march-native \
    --enable-openmp \
    ${SSE_OPT} --disable-avx \
    --disable-phi --without-opencl \
    --without-cuda --enable-emu \
    --disable-doxygen-doc \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} V=1 2>&1 | tee build.log
make check 2>&1 | tee check.log


## Install
make install
