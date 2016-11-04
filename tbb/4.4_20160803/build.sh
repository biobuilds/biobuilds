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
    TBB_COMPILER="clang"
    SHARED_LIB_EXT="dylib"

    MACOSX_VERSION_MIN="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # For C++11 support and compatibility with other BioBuilds C++ applications
    # and libraries (particularly Boost), link the OS X dynamic libraries with
    # libc++ instead of the OS X 10.8 standard of libstdc++.
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
elif [ "$build_os" == 'Linux' ]; then
    TBB_COMPILER="gcc"
    SHARED_LIB_EXT="so"
else
    abort "unsupported OS '$build_os'"
fi

if [ "$build_arch" == 'x86_64' ]; then
    # Assuming microarchitecture is Nehalem or later, so we can safely enable
    # SSE4.x instructions; not an unreasonable assumption since this was
    # introduced in 2008. WARNING: do *NOT* change "-march" from "core2" to
    # more recent microarchitectures (e.g., "corei7"), as those values are not
    # recognized by gcc 4.4.x used by CentOS 6.
    CXXFLAGS="${CXXFLAGS} -m64 -march=core2 -mfpmath=sse"
    CXXFLAGS="${CXXFLAGS} -mmmx -msse -msse2 -msse3 -mssse3"
    CXXFLAGS="${CXXFLAGS} -msse4 -msse4.1 -msse4.2 -mpopcnt"

    # If the compiler supports it, explicitly disable use of RTM hardware
    # instructions (XABORT, XBEGIN, XEND); these were introduced in Haswell,
    # but our build needs to support older x86_64 microarchitectures.
    set +e
    ${TBB_COMPILER} -mno-rtm -E - </dev/null >/dev/null
    if [ $? -eq 0 ]; then
        CXXFLAGS="${CXXFLAGS} -mno-rtm"
    fi
    set -e
elif [ "$build_arch" == 'ppc64le' ]; then
    # Assuming microarchitecture is POWER8 or later
    CXXFLAGS="${CXXFLAGS} -m64 -mcpu=power8 -mtune=power8"
    CXXFLAGS="${CXXFLAGS} -maltivec -mvsx"
else
    abort "unsuported architecture '$build_arch'"
fi


## Build
make -j${BB_MAKE_JOBS} cfg=release tbb_build_prefix=libs \
    compiler=${TBB_COMPILER} CXXFLAGS="${CXXFLAGS}" \
    lambdas=1 RTM_KEY="" \
    2>&1 | tee build.log

# Disabling this for now; some of the tests seem to be hanging in our OS X
# build VM, even though there seem to be no functional problems running when
# running on # "real" hardware.
#make -j${BB_MAKE_JOBS} cfg=release tbb_build_prefix=libs \
#    compiler=${TBB_COMPILER} CXXFLAGS="${CXXFLAGS}" \
#    test \
#    2>&1 | tee test.log


## Install
mkdir -p "${PREFIX}/lib" "${PREFIX}/include"
cp build/libs_release/libtbb*.${SHARED_LIB_EXT}* "${PREFIX}/lib"
chmod 0755 ${PREFIX}/lib/libtbb*.${SHARED_LIB_EXT}*
cp -rvf include/tbb "${PREFIX}/include/tbb"
find "${PREFIX}/include/tbb" -name '*.html' | xargs rm -f
find "${PREFIX}/include/tbb" -type f | xargs chmod 0644
