#!/bin/bash

set -o pipefail
set -e -x

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

CFLAGS="${CFLAGS} -I${PREFIX}/include"
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"


# bwa's Makefile and sources need to be patched *after* its source tarball is
# extracted; this can't be directly done by "conda build", so just put the
# patch in ${SRC_DIR} and let cmake's ExternalProject_Add() to apply it.
cp -fv "${RECIPE_DIR}/bwa-makefile.patch" "${SRC_DIR}/bwa.patch"

if [ `uname -m` == 'ppc64le' ]; then
    # Needed to convert x86_64 vector intrinsics in to POWER8 ones
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
    CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"
    cat "${RECIPE_DIR}/bwa-ppc64le.patch" >> "${SRC_DIR}/bwa.patch"
fi

if [ `uname -s` == 'Darwin' ]; then
    # Let Xcode (clang and ld) handle the target platform instead of passing
    # the "CMAKE_OSX_DEPLOYMENT_TARGET" option to cmake, as doing the latter
    # simply generate a bunch of annoying warning messages.
    export MACOSX_DEPLOYMENT_TARGET="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"

    # WARNING: linking against libc++ breaks compatibility with the boost
    # libraries in the conda "defaults" channel. However, we need this to get
    # proper C++11 support for building OS X binaries.
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

# cmake requires us to build outside the source directory
[ -d build ] || mkdir -p build

# Clean up previous builds
rm -rf build/*
[ -d external ] && \
    find external -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

# Run cmake to configure the build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DZLIB_INCLUDEDIR:PATH="${PREFIX}/include" \
    -DZLIB_LIBRARYDIR:PATH="${PREFIX}/lib" \
    -DBOOST_INCLUDEDIR:PATH="${PREFIX}/include" \
    -DBOOST_LIBRARYDIR:PATH="${PREFIX}/lib" \
    -DCOMMON_C_FLAGS:STRING="${CFLAGS}" \
    -DCOMMON_CXX_FLAGS:STRING="${CXXFLAGS}" \
    -DCOMMON_LD_FLAGS:STRING="${LDFLAGS}" \
    .. 2>&1 | tee configure.log

## Build
# WARNING: do NOT use make's "-j<N>" option, as that causes build failures.
make 2>&1 | tee build.log

## Install
make install

## Test (ARGS argument runs ctest in extra-verbose mode)
mkdir -p "${PREFIX}/tests"
cp -f -v -p src/unitTests "${PREFIX}/tests"
cp -f -v "${SRC_DIR}/sample_data.tgz" "${PREFIX}"
env DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    LD_LIBRARY_PATH="${PREFIX}/lib" \
    make test ARGS="-VV"

# Clean up test data so it doesn't end up in our conda package
rm -rf ${PREFIX}/sample_data.tgz ${PREFIX}/sample_data
rm -rf ${PREFIX}/tests

## Don't need the salmon static library at runtime
rm -f ${PREFIX}/lib/libsalmon*.a
