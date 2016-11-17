#!/bin/bash
set -e -x
set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -I${PREFIX}/include"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$build_os" == 'Darwin' ]; then
    MACOSX_VERSION_MIN="10.8"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi


## Build
rm -f source/makefile
env CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
    make -j${BB_MAKE_JOBS} \
    PREFIX="${PREFIX}" \
    64BIT_VERSION=yes \
    OPTIMIZE=yes \
    USERREADLINE=yes \
    READLINE_LIBS="-lreadline -lncurses" \
    USEBOOST=yes \
    BOOST_INCLUDE_DIR="${PREFIX}/include" \
    BOOST_LIBRARY_DIR="${PREFIX}/lib" \
    2>&1 | tee build.log


## Install
install -m 0755 -d "${PREFIX}/bin"
install -m 0755 mothur uchime "${PREFIX}/bin"
