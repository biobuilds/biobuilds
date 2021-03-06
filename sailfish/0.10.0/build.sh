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
    .. 2>&1 | tee configure.log

## Build
make 2>&1 | tee build.log

## Install
make install

## Test (ARGS argument runs ctest in extra-verbose mode)
cp -f -v "${SRC_DIR}/sample_data.tgz" "${PREFIX}"
env DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib" \
    LD_LIBRARY_PATH="${PREFIX}/lib" \
    make test ARGS="-VV"

# Clean up test data so it doesn't end up in our conda package
rm -rf ${PREFIX}/sample_data.tgz ${PREFIX}/sample_data
rm -rf ${PREFIX}/tests

# Don't need the sailfish static library at runtime
rm -f ${PREFIX}/lib/libsailfish*.a
