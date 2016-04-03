#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"

CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$build_arch" == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
fi

if [ "$build_os" == 'Darwin' ]; then
    MACOSX_VERSION_MIN=10.8
    CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CFLAGS="${CFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi


## Build
env CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    make -C src -j${BB_MAKE_JOBS} BAMTOOLS_ROOT="$PREFIX" \
    2>&1 | tee build.log
env CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    make -C test -j${BB_MAKE_JOBS} \
    2>&1 | tee test.log


## Install
mkdir -p "${PREFIX}/bin"
install -m 0755 bin/freebayes bin/bamleftalign "${PREFIX}/bin"
