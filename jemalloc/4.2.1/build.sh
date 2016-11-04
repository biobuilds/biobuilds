#!/bin/bash

set -o pipefail
set -e -x

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}


## Configure
[ "${BB_MAKE_JOBS}" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
build_arch=`uname -m`
build_os=`uname -s`

if [ "$build_os" == 'Darwin' ]; then
    MACOSX_VERSION_MIN="10.8"
    CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
elif [ "$build_os" == 'Linux' ]; then
    :   # no special configuration needed for Linux
else
    abort "unsupported OS '$build_os'"
fi

if [ "$build_arch" == 'x86_64' ]; then
    # Assuming microarchitecture is Nehalem or later, so we can safely enable
    # SSE4.x instructions; not an unreasonable assumption since this was
    # introduced in 2008. WARNING: do *NOT* change "-march" from "core2" to
    # more recent microarchitectures (e.g., "corei7"), as those values are not
    # recognized by gcc 4.4.x used by CentOS 6.
    CFLAGS="${CFLAGS} -m64 -march=core2 -mfpmath=sse"
    CFLAGS="${CFLAGS} -mmmx -msse -msse2 -msse3 -mssse3"
    CFLAGS="${CFLAGS} -msse4 -msse4.1 -msse4.2 -mpopcnt"
elif [ "$build_arch" == 'ppc64le' ]; then
    # Assuming microarchitecture is POWER8 or later
    CFLAGS="${CFLAGS} -m64 -mcpu=power8 -mtune=power8"
    CFLAGS="${CFLAGS} -maltivec -mvsx"
else
    abort "unsuported architecture '$build_arch'"
fi

env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --disable-debug \
    --disable-prof \
    --disable-stats \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
make -j${BB_MAKE_JOBS} check 2>&1 | tee test.log
make install

cd "${PREFIX}"
rm -rfv lib/libjemalloc*.a share/doc/jemalloc
