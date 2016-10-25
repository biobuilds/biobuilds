#!/bin/bash

CFLAGS="${CFLAGS} -O3"
CXXFLAGS="${CXXFLAGS} -O3"

if [ `uname -s` == 'Darwin' ]; then
    # Linking to libstdc++ instead of libc++ to maintain compatibility with the
    # ICU libraries available from conda's "defaults" channel.
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LDFLAGS="${LDFLAGS} -stdlib=libstdc++"
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
