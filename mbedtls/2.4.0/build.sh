#!/bin/bash

set -e -x -o pipefail

build_os=`uname -s`
build_arch=`uname -m`


## Configure
mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"
rm -rf *

if [ "$build_arch" == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -m64 -mcpu=power8 -mtune=power8"
elif [ "$build_arch" == 'x86_64' ]; then
    CFLAGS="${CFLAGS} -m64 -mcpu=core2 -mtune=core2"
else
    echo "*** ERROR: Unsupported architecture '$build_arch' ***" >&2
    exit 1
fi

if [ "$build_os" == 'Darwin' ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.8"
fi

cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DENABLE_PROGRAMS:BOOL=OFF \
    -DENABLE_ZLIB_SUPPORT:BOOL=ON \
    -DINSTALL_MBEDTLS_HEADERS:BOOL=ON \
    -DUSE_SHARED_MBEDTLS_LIBRARY:BOOL=ON \
    "${SRC_DIR}" \
    2>&1 | tee configure.log


## Build
make V=1 -j${CPU_COUNT} 2>&1 | tee build.log
make test 2>&1 | tee test.log


## Install
make install
