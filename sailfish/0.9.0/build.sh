#!/bin/bash

set -o pipefail

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# cmake requires us to build outside the source directory
[ -d build ] || mkdir -p build

# Clean up previous builds
rm -rf build/*
[ -d external ] && \
    find external -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

# Run cmake to configure the build; notes:
# - Need to set NO_RTM to avoid "no such instruction" messages related to TSX
#   extensions (xabort, xbegin, xend, xtest) when building libtbb on x86_64;
#   in any case, we don't want TSX extensions since those were introduced in
#   Haswell, and our build should support architectures older than that.
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DZLIB_INCLUDEDIR:PATH="${PREFIX}/include" \
    -DZLIB_LIBRARYDIR:PATH="${PREFIX}/lib" \
    -DBOOST_INCLUDEDIR:PATH="${PREFIX}/include" \
    -DBOOST_LIBRARYDIR:PATH="${PREFIX}/lib" \
    -DCOMMON_C_FLAGS:STRING="${CFLAGS}" \
    -DCOMMON_CXX_FLAGS:STRING="${CFLAGS}" \
    -DNO_RTM=TRUE \
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
