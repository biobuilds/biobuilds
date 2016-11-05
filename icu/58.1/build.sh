#!/bin/bash

CFLAGS="${CFLAGS} -O3"
CXXFLAGS="${CXXFLAGS} -O3"

if [ `uname -s` == 'Darwin' ]; then
    MACOSX_VERSION_MIN=10.8
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # WARNING: using "libc++" instead of "libstdc++" as our C++ stdlib breaks
    # compatibility with the "defaults" channel's ICU package. However, to make
    # our OS X boost packages usable with C++11 applications, we need to link
    # to use "libc++" (see comments in boost/1.60/build.sh for details).
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

cd source
env CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
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
make -j${BB_MAKE_JOBS:-1}
make install
