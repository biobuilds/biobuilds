#!/bin/bash

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CXXFALGS="${CXXFLAGS} -fsigned-char"

if [ -x "${PREFIX}/bin/g++" ]; then
    CXX="${PREFIX}/bin/g++"
else
    CXX=$(command -v g++)
fi

mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_CXX="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    .. 2>&1 | tee configure.log


## Build
make splazers


## Install
mkdir -p "${PREFIX}/bin"
install -m 0755 bin/splazers "${PREFIX}/bin"
