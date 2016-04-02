#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
#CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$build_arch" == "ppc64le" ]; then
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib -Wno-deprecated"
fi

# Needed so ./configure test programs don't fail
if [ "$build_os" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

cd "${SRC_DIR}/src"
[ -f ./Makefile ] && make distclean
autoconf -f
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix=${PREFIX} --with-beagle=${PREFIX} \
    --enable-sse=yes --enable-threads=yes --enable-mpi=no \
    2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log


## Install
mkdir -p "${PREFIX}/bin"
install -m 0755 mb "${PREFIX}/bin"
