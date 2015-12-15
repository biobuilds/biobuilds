#!/bin/bash

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

cp -f "${PREFIX}/share/autoconf/config.guess" config/config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" config/config.sub

if [ `uname -s` == 'Darwin' ]; then
    # Needed to ensure libgcc is found when running "make check"
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

env CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --enable-wall --disable-debug \
    --with-pic --enable-shared --enable-static \
    2>&1 | tee configure.log
make -j${BB_MAKE_JOBS}
make check

make install

# Fix issue where headers get installed one level too deep
cd "${PREFIX}/include/gtextutils"
mv gtextutils/*.h gtextutils/*.hpp .
rmdir gtextutils
