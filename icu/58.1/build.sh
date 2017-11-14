#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

if [ `uname -s` == 'Darwin' ]; then
    # WARNING: using "libc++" instead of "libstdc++" as our C++ stdlib breaks
    # compatibility with the "defaults" channel's ICU package. However, to make
    # our OS X boost packages usable with C++11 applications, we need to link
    # to use "libc++" (see comments in boost/1.60/build.sh for details).
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

cd source
env CC="$CC" CFLAGS="$CFLAGS" \
    CXX="$CXX" CXXFLAGS="$CXXFLAGS" \
    LD="$LD" LDFLAGS="$LDFLAGS" \
    ./configure --prefix="$PREFIX" \
    --enable-release \
    --disable-debug \
    --disable-tracing \
    --with-library-bits=64 \
    --enable-shared \
    --disable-static \
    --enable-rpath \
    --disable-samples \
    --disable-tests \
    2>&1 | tee configure.log
make -j${MAKE_JOBS} VERBOSE=1
make install
