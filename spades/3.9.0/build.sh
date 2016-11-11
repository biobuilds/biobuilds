#!/bin/bash

set -e -x
set -o pipefail

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Make sure the compiler and linker can find zlib and htslib
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Force the ppc64le compiler to make the same assumptions about "plain" char
# declarations (i.e., those w/o explicit sign) as x86_64 Linux gcc/g++.
CFLAGS="${CFLAGS} -fsigned-char"

# Platform-specific tweaks
if [ `uname -m` == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"
fi

mkdir -p build
rm -rf build/*
cd "build"
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DSPADES_USE_JEMALLOC:BOOL=ON \
    -DSPADES_USE_TCMALLOC:BOOL=OFF \
    "${SRC_DIR}/src" \
    2>&1 | tee configure.log

make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
make install
